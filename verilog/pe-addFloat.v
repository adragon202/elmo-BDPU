
module add_f32(a, b, sum, a_greater, exp_diff, sum_exp, mant_sum);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	// inputs 
	input [WIDTH - 1:0] a, b;
	// outputs
	output [WIDTH - 1:0] sum;
	output a_greater;
	output [EXPONENTWIDTH - 1:0] exp_diff;
	output [MANTISSAWIDTH - 1:0] mant_sum;
	output [EXPONENTWIDTH - 1:0] sum_exp;
	// internal wires
	wire a_sign							= a[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] a_exp	= a[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH - 1:0] a_mant	= a[MANTISSAWIDTH-1:0];
	wire b_sign							= b[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] b_exp	= b[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH - 1:0] b_mant	= b[MANTISSAWIDTH-1:0];
	wire [EXPONENTWIDTH - 1:0] exp_diff;
	wire [EXPONENTWIDTH - 1:0] exp_neg;
	wire [MANTISSAWIDTH - 1:0] mant_sum;
	wire a_greater; //indicates if a is greater or lesser than b
	wire a_exp_greater;
	reg in1_sign;
	reg in2_sign;
	reg [EXPONENTWIDTH - 1:0] in_exp;
	reg [MANTISSAWIDTH - 1:0] in1_mant;
	wire [MANTISSAWIDTH - 1:0] in1_mant_neg;
	reg [MANTISSAWIDTH - 1:0] in2_mant;
	wire [MANTISSAWIDTH - 1:0] in2_mant_neg;
	reg sum_sign;
	wire [EXPONENTWIDTH - 1:0] sum_exp;
	reg [MANTISSAWIDTH - 1:0] sum_mant;
	wire sum_mant_carry;

	//Evalute the greater of a_exp or b_exp so that a > b
	//If b is negative and a is not
	//If b exponent is less than a
	//If b mantissa is less than a
	assign a_exp_greater = (a_exp > b_exp);
	assign a_greater = (a_sign != b_sign && a_sign == 0) || ((a_exp > b_exp && a_sign == 0) || (a_exp < b_exp && a_sign == 1)) || ((a_mant > b_mant && a_sign == 0 && a_exp == b_exp) || (a_mant < b_mant && a_sign == 1 && a_exp == b_exp));

	//Consider b_exp = a_exp
	//Shift b_mant to the right by a_exp - b_exp
	adder8 add8_expneg(.a((a_exp_greater == 1) ? ~(b_exp) :  ~(a_exp)), .b(1), .cin(1'b0), .sum(exp_neg), .cout(), .PG(), .GG());
	adder8 add8_expdiff(.a((a_exp_greater == 1) ? a_exp : exp_neg), .b((a_exp_greater == 0) ? b_exp : exp_neg), .cin(1'b1), .sum(exp_diff), .cout(), .PG(), .GG());
	always @(exp_diff) begin
		//Assign registers for remainder of calculations
		in1_sign <= (a_greater == 1) ? a_sign : b_sign;
		in2_sign <= (a_greater == 0) ? a_sign : b_sign;
		in_exp	 <= (a_greater == 1) ? a_exp  : b_exp; //After this step exponents will be equal
		in1_mant <= ((a_greater == 1) ? a_mant : b_mant) >> 1;
		//Shift in2 as the lesser value
		in2_mant <= ((a_greater == 0) ? a_mant : b_mant) >> exp_diff;
	end

	//Create Negative formats for proper addition
	adder24 add24_mant1_neg(.a({1'b1,~(in1_mant)}), .b({24'd1}), .cin(0), .sum({in1_mant_neg}));
	adder24 add24_mant2_neg(.a({1'b1,~(in2_mant)}), .b({24'd1}), .cin(0), .sum({in2_mant_neg}));
	//Sum mantissa's
	adder24 add24_mantsum(.a((in1_sign == 0) ? {1'b0,in1_mant} : {1'b1,in1_mant_neg}), .b((in1_sign == 0) ? {1'b0,in2_mant} : {1'b1,in2_mant_neg}), .cin(1'b0), .sum(mant_sum), .cout(sum_mant_carry));

	//Normalize
	//Adjust resulting Exponent
	adder8 add8_sumexp(.a(in_exp), .b({7'b0,(sum_mant_carry == 1)}), .cin(1'b0), .sum(sum_exp));
	always @(mant_sum) begin
		if (sum_mant_carry == 1) begin
			sum_mant <= mant_sum >> 1;
			sum_mant[MANTISSAWIDTH-1] <= 1;
		end else begin
			sum_mant <= mant_sum;
		end
	end

	assign sum = ((a_greater == 1 && a_sign == 1) || (a_greater == 0 && b_sign == 1)) ? {1'b1, sum_exp, sum_mant} : {1'b0, sum_exp, sum_mant};

endmodule //add_f32
