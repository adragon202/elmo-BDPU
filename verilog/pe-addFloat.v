
module add_f32(a,b,sum);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	// inputs 
	input [WIDTH - 1:0] a, b;
	// outputs
	output [WIDTH - 1:0] sum;
	// internal wires
	wire a_sign							= a[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] a_exp	= a[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH - 1:0] a_mant	= a[MANTISSAWIDTH-1:0];
	wire b_sign						= b[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] b_exp	= b[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH - 1:0] b_mant	= b[MANTISSAWIDTH-1:0];
	wire [EXPONENTWIDTH - 1:0] exp_diff;
	wire [EXPONENTWIDTH - 1:0] exp_neg;
	wire [MANTISSAWIDTH - 1:0] mant_sum;
	wire a_greater; //indicates if a is greater or lesser than b
	reg in_sign;
	reg [EXPONENTWIDTH - 1:0] in_exp;
	reg [MANTISSAWIDTH - 1:0] in1_mant;
	reg [MANTISSAWIDTH - 1:0] in2_mant;
	reg sum_sign;
	wire [EXPONENTWIDTH - 1:0] sum_exp;
	reg [MANTISSAWIDTH - 1:0] sum_mant;
	wire sum_mant_carry;
	reg i;

	//Evalute the greater of a_exp or b_exp so that a > b
	//If b is negative and a is not
	//If b exponent is less than a
	//If b mantissa is less than a
	assign a_greater = (a_sign != b_sign && a_sign == 0) || ((a_exp > b_exp && a_sign == 0) || (a_exp < b_exp && a_sign == 1)) || ((a_mant > b_mant && a_sign == 0) || (a_mant < b_mant && a_sign == 1));

	//Consider b_exp = a_exp
	//Shift b_mant to the right by a_exp - b_exp
	adder8 add8_expneg(.a((a_greater == 1) ? ~(b_exp) :  ~(a_exp)), .b(1), .cin(1'b0), .sum(exp_neg), .cout(), .PG(), .GG());
	adder8 add8_expdiff(.a((a_greater == 1) ? a_exp : exp_neg), .b((a_greater == 0) ? b_exp : exp_neg), .cin(1'b0), .sum(exp_diff), .cout(), .PG(), .GG());
	always @(exp_diff) begin
		//Assign registers for remainder of calculations
		in_sign <= (a_greater == 1) ? a_sign : b_sign;
		in_exp	 <= (a_greater == 1) ? a_exp  : b_exp; //After this step exponents will be equal
		in1_mant <= (a_greater == 1) ? a_mant : b_mant;
		in2_mant <= (a_greater == 0) ? a_mant : b_mant;
		//Shift in2 as the lesser value
		for (i = 0; i < exp_diff; i = i + 1)
		begin:mantissa_shift
			in2_mant = in2_mant >> 1;
		end
	end

	//Sum mantissa's (Apply negative to mantissa)
	adder24 add24_mantsum(.a({1'b0,in1_mant}), .b({1'b0,in2_mant}), .cin(1'b0), .sum(mant_sum), .cout(sum_mant_carry));

	//Normalize
	//Adjust resulting Exponent
	adder8 add8_sumexp(.a(in_exp), .b({7'd0,(sum_mant_carry == 1) ? 1 : 0}), .cin(1'b0), .sum(sum_exp));
	always @(mant_sum) begin
		sum_mant <= mant_sum;
		if (sum_mant_carry == 1) begin
			sum_mant = sum_mant >> 1;
			sum_mant[MANTISSAWIDTH-1] <= 1;
		end
	end

	assign sum = {1'b0, sum_exp, sum_mant};

endmodule //add_f32
