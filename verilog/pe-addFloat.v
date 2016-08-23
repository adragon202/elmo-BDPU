
//Rounding error will occur, causing some results to be off by 1 in hex or binary,
//Error will only be to the last decimal place.
module add_f32(a, b, sum, a_greater, exp_diff, sum_exp, sum_mant, mant_sum, out1_mant, out2_mant);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 24; //Input and output Mantissa will be 23 bits
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
	wire [EXPONENTWIDTH - 1:0] a_exp	= a[WIDTH - 2:MANTISSAWIDTH-1];
	wire [MANTISSAWIDTH - 1:0] a_mant	= {1'b1,a[MANTISSAWIDTH-2:0]}; //result is the mantissa with a leading 1. (1.mant)
	wire b_sign							= b[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] b_exp	= b[WIDTH - 2:MANTISSAWIDTH-1];
	wire [MANTISSAWIDTH - 1:0] b_mant	= {1'b1,b[MANTISSAWIDTH-2:0]}; //result is the mantissa with a leading 1. (1.mant)
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
	wire sum_mant_carry;


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
						.cin(1'd1),
						.sum(exp_neg));
	adder8 add8_expdiff(.a((a_exp_greater == 1) ? a_exp : exp_neg),
						.b((a_exp_greater == 0) ? b_exp : exp_neg),
						.cin(1'd0),
						.sum(exp_diff));
	assign in1_sign = (a_greater) ? a_sign : b_sign;
	assign in2_sign = (!a_greater) ? a_sign : b_sign;
	always @(*) begin
		//Assign registers for remainder of calculations
		in_exp	 <= (a_greater == 1) ? a_exp  : b_exp; //After this step exponents will be equal
		//Shift in2 as the lesser value
		if (exp_diff == 0) begin
			in1_mant <= ((a_greater == 1) ? a_mant : b_mant) >> 1;
			in2_mant <= ((a_greater == 0) ? a_mant : b_mant) >> 1;
		end else begin
			in1_mant <= ((a_greater == 1) ? a_mant : b_mant);
			in2_mant <= ((a_greater == 0) ? a_mant : b_mant) >> (exp_diff);
		end
	end

	//Create Negative formats for proper addition
	adder24 add24_mant1_neg(.a(~(in1_mant)), .b({23'b0,1'b1}), .cin(1'd0), .sum(in1_mant_neg));
	adder24 add24_mant2_neg(.a(~(in2_mant)), .b({23'b0,1'b1}), .cin(1'd0), .sum(in2_mant_neg));
	//Sum mantissa's
	adder24 add24_mantsum(.a((in1_sign == 0) ? in1_mant : in1_mant_neg),
							.b((in2_sign == 0) ? in2_mant : in2_mant_neg),
							.cin(1'b0),
							.sum(mant_sum), .cout(sum_mant_carry));

	//Normalize
	//Adjust resulting Exponent
	//If the exponent difference was only 0 or 1, then the exponent increments or decrements depending on the greater values sign
	adder8 add8_sumexp(.a(in_exp),
						.b({7'b0,(a_exp == b_exp) ? 1'd1 : sum_mant_carry}),
						.cin(1'b0),
						.sum(sum_exp));
	//Undo two's compliment on mantissa when the result is negative.
	adder24 add24_mantsum_neg(.a(~(mant_sum)), .b({23'b0,1'b1}), .cin(1'd0), .sum(mant_sum_neg));

	always @(*) begin
		sum_mant <= mant_sum;
	end

	assign sum = ((a_greater == 1 && a_sign == 1) || (a_greater == 0 && b_sign == 1)) ? {1'b1, sum_exp, sum_mant[MANTISSAWIDTH-2:0]} : {1'b0, sum_exp, sum_mant[MANTISSAWIDTH-2:0]};

endmodule //add_f32
