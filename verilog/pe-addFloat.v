
module add_f32(a, b, sum, a_greater, exp_diff, sum_exp, sum_mant, mant_sum, out1_mant, out2_mant);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	// inputs 
	input [WIDTH - 1:0] a, b;
	// outputs
	output [WIDTH - 1:0] sum;
	//*********************************************************************
	//For Debug Purposes
	output a_greater;
	output [EXPONENTWIDTH - 1:0] exp_diff;
	output [MANTISSAWIDTH - 1:0] mant_sum;
	output [MANTISSAWIDTH - 1:0] sum_mant;
	output [EXPONENTWIDTH - 1:0] sum_exp;
	output [MANTISSAWIDTH - 1:0] out1_mant;
	output [MANTISSAWIDTH - 1:0] out2_mant;
	assign out1_mant = (!in1_sign) ? {1'b0,in1_mant} : {1'b1,in1_mant_neg};
	assign out2_mant = (!in2_sign) ? {1'b0,in2_mant} : {1'b1,in2_mant_neg};
	//*********************************************************************
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
	wire [MANTISSAWIDTH - 1:0] mant_sum_neg;
	wire a_greater; //indicates if a is greater or lesser than b
	wire a_exp_greater;
	wire in1_sign;
	wire in2_sign;
	reg [EXPONENTWIDTH - 1:0] in_exp;
	reg [MANTISSAWIDTH - 1:0] in1_mant;
	wire [MANTISSAWIDTH - 1:0] in1_mant_neg;
	reg [MANTISSAWIDTH - 1:0] in2_mant;
	wire [MANTISSAWIDTH - 1:0] in2_mant_neg;
	reg sum_sign;
	wire [EXPONENTWIDTH - 1:0] sum_exp;
	reg [MANTISSAWIDTH - 1:0] sum_mant;
	wire [1:0] sum_mant_carry;


	//Evalute the greater of a_exp or b_exp so that a > b
	//If b is negative and a is not
	//If b exponent is less than a
	//If b mantissa is less than a
	assign a_exp_greater = (a_exp > b_exp);
	assign a_greater = (a_sign != b_sign && a_sign == 0) || ((a_exp > b_exp && a_sign == 0) || (a_exp < b_exp && a_sign == 1)) || ((a_mant > b_mant && a_sign == 0 && a_exp == b_exp) || (a_mant < b_mant && a_sign == 1 && a_exp == b_exp));

	//Consider b_exp = a_exp
	//Shift b_mant to the right by a_exp - b_exp
	adder8 add8_expneg(.a((a_exp_greater == 1) ? ~(b_exp) :  ~(a_exp)),
						.b(8'b0),
						.cin(1),
						.sum(exp_neg));
	adder8 add8_expdiff(.a((a_exp_greater == 1) ? a_exp : exp_neg),
						.b((a_exp_greater == 0) ? b_exp : exp_neg),
						.cin(0),
						.sum(exp_diff));
	assign in1_sign = (a_greater) ? a_sign : b_sign;
	assign in2_sign = (!a_greater) ? a_sign : b_sign;
	always @(exp_diff) begin
		//Assign registers for remainder of calculations
		in_exp	 <= (a_greater == 1) ? a_exp  : b_exp; //After this step exponents will be equal
		//Shift in2 as the lesser value
		if (exp_diff == 0) begin
			in1_mant <= ((a_greater == 1) ? a_mant : b_mant) >> 1;
			in2_mant <= ((a_greater == 0) ? a_mant : b_mant) >> 1;
		end else begin
			in1_mant <= ((a_greater == 1) ? a : b);
			in2_mant <= ((a_greater == 0) ? a : b) >> (exp_diff);
		end
	end

	//Create Negative formats for proper addition
	adder24 add24_mant1_neg(.a({1'b1,~(in1_mant)}), .b({23'b0,1'b1}), .cin(0), .sum({X,in1_mant_neg}));
	adder24 add24_mant2_neg(.a({1'b1,~(in2_mant)}), .b({23'b0,1'b1}), .cin(0), .sum({X,in2_mant_neg}));
	//Sum mantissa's
	adder24 add24_mantsum(.a((in1_sign == 0) ? {1'b0,in1_mant} : {1'b1,in1_mant_neg}),
							.b((in2_sign == 0) ? {1'b0,in2_mant} : {1'b1,in2_mant_neg}),
							.cin(1'b0),
							.sum({sum_mant_carry[0], mant_sum}), .cout(sum_mant_carry[1]));

	//Normalize
	//Adjust resulting Exponent
	//If the exponent difference was only 0 or 1, then the exponent increments or decrements depending on the greater values sign
	adder8 add8_sumexp(.a(in_exp),
						.b((exp_diff < 2) ? ( ((a_greater && a_sign) || (!a_greater && b_sign)) ? {7'b1,1'b1} : {7'b0,1'b1} )
							: {6'b0,sum_mant_carry}),
						.cin(1'b0),
						.sum(sum_exp));
	//Undo two's compliment on mantissa when the result is negative.
	adder24 add24_mantsum_neg(.a({1'b1,~(mant_sum)}), .b({23'b0,1'b1}), .cin(0), .sum({X,mant_sum_neg}));

	always @(mant_sum or mant_sum_neg) begin
		if (sum_mant_carry[0] == 1) begin
			sum_mant <= {1'b1,((!in1_sign) ? mant_sum[MANTISSAWIDTH-1:1] : mant_sum_neg[MANTISSAWIDTH-1:1])};
		end else begin
			sum_mant <= ((!in1_sign) ? mant_sum : mant_sum_neg);
		end
	end

	assign sum = ((a_greater == 1 && a_sign == 1) || (a_greater == 0 && b_sign == 1)) ? {1'b1, sum_exp, sum_mant} : {1'b0, sum_exp, sum_mant};

endmodule //add_f32
