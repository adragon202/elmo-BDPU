
//Rounding error will occur, causing some results to be off by 1 in hex or binary,
//Error will only be to the last decimal place.
module add_f32(a, b, sum, exp_diff, sum_exp, in_exp, sum_mant, mant_sum_shift, mant_sum, out1_mant, out2_mant);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 25; //Input and output Mantissa will be 23 bits
	// inputs 
	input [WIDTH - 1:0] a, b;
	// outputs
	output [WIDTH - 1:0] sum;
	//*********************************************************************
	//For Debug Purposes
	output [EXPONENTWIDTH - 1:0] exp_diff;
	output [MANTISSAWIDTH - 1:0] mant_sum;
	output [MANTISSAWIDTH - 2:0] sum_mant;
	output [EXPONENTWIDTH - 1:0] sum_exp;
	output [EXPONENTWIDTH - 1:0] in_exp;
	output [MANTISSAWIDTH - 1:0] out1_mant;
	output [MANTISSAWIDTH - 1:0] out2_mant;
	output [4:0] mant_sum_shift;
	assign out1_mant = (!in1_sign) ? {1'b0,in1_mant} : {1'b1,in1_mant_neg};
	assign out2_mant = (!in2_sign) ? {1'b0,in2_mant} : {1'b1,in2_mant_neg};
	//*********************************************************************
	// internal wires
	wire a_sign							= a[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] a_exp	= a[WIDTH - 2:MANTISSAWIDTH-2];
	wire [MANTISSAWIDTH - 1:0] a_mant	= {2'b01,a[MANTISSAWIDTH-3:0]}; //result is the mantissa with a leading 1. (1.mant)
	wire b_sign							= b[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] b_exp	= b[WIDTH - 2:MANTISSAWIDTH-2];
	wire [MANTISSAWIDTH - 1:0] b_mant	= {2'b01,b[MANTISSAWIDTH-3:0]}; //result is the mantissa with a leading 1. (1.mant)
	wire [EXPONENTWIDTH - 1:0] exp_diff;
	wire [EXPONENTWIDTH - 1:0] exp_neg;
	wire [MANTISSAWIDTH - 1:0] mant_sum;
	wire [4:0] mant_sum_shift;
	wire [MANTISSAWIDTH - 1:0] mant_sum_neg;
	wire mant_sum_sign;
	wire a_abs_greater;
	wire a_exp_greater;
	wire in1_sign;
	wire in2_sign;
	reg [EXPONENTWIDTH - 1:0] in_exp;
	reg [MANTISSAWIDTH - 1:0] in1_mant;
	wire [MANTISSAWIDTH - 1:0] in1_mant_neg;
	reg [MANTISSAWIDTH - 1:0] in2_mant;
	wire [MANTISSAWIDTH - 1:0] in2_mant_neg;
	wire [EXPONENTWIDTH - 1:0] sum_exp;
	reg [MANTISSAWIDTH - 1:0] sum_mant;
	wire sum_mant_carry;
	reg rslt_sign;
	reg [EXPONENTWIDTH - 1:0] rslt_exp;
	reg [MANTISSAWIDTH - 3:0] rslt_mant;


	//Evalute the greater of a_exp or b_exp so that a > b
	//If b is negative and a is not
	//If b exponent is less than a
	//If b mantissa is less than a
	assign a_exp_greater = (a_exp > b_exp);
	assign a_abs_greater = (a_exp > b_exp) || (a_mant > b_mant && a_exp == b_exp);

	//Consider b_exp = a_exp
	//Shift b_mant to the right by a_exp - b_exp
	adder8 add8_expneg(.a((a_exp_greater) ? ~(b_exp) :  ~(a_exp)),
						.b(8'b0),
						.cin(1'd1),
						.sum(exp_neg));
	adder8 add8_expdiff(.a((a_exp_greater) ? a_exp : exp_neg),
						.b((!a_exp_greater) ? b_exp : exp_neg),
						.cin(1'd0),
						.sum(exp_diff));
	assign in1_sign = (a_exp_greater) ? a_sign : b_sign;
	assign in2_sign = (!a_exp_greater) ? a_sign : b_sign;
	always @(*) begin
		//Assign registers for remainder of calculations
		in_exp	 <= (a_exp_greater) ? a_exp  : b_exp; //After this step exponents will be equal
		//Shift in2 as the lesser value
		if (exp_diff == 0) begin
			in1_mant <= ((a_exp_greater) ? a_mant : b_mant);
			in2_mant <= ((!a_exp_greater) ? a_mant : b_mant);
		end else begin
			in1_mant <= ((a_exp_greater) ? a_mant : b_mant);
			in2_mant <= ((!a_exp_greater) ? a_mant : b_mant) >> (exp_diff);
		end
	end

	//Create Negative formats for proper addition
	adder25 add25_mant1_neg(.a(~(in1_mant)), .b(24'b0), .cin(1'd1), .sum(in1_mant_neg));
	adder25 add25_mant2_neg(.a(~(in2_mant)), .b(24'b0), .cin(1'd1), .sum(in2_mant_neg));
	//Sum mantissa's
	adder25 add25_mantsum(.a((!in1_sign) ? in1_mant : in1_mant_neg),
							.b((!in2_sign) ? in2_mant: in2_mant_neg),
							.cin(1'b0),
							.sum(mant_sum), .cout());

	//Normalize
	//Adjust resulting Exponent
	leading_zeroes_25 leading_zeroes_mant((mant_sum_sign ? mant_sum_neg[MANTISSAWIDTH-2:0] : mant_sum[MANTISSAWIDTH-2:0]), mant_sum_shift);
	//If the exponent difference was only 0 or 1, then the exponent increments or decrements depending on the greater values sign
	adder8 add8_sumexp(.a(in_exp),
						.b((mant_sum[MANTISSAWIDTH-1] && a_sign == 0 && b_sign == 0) || (!mant_sum[MANTISSAWIDTH-1] && a_sign == 1 && b_sign == 1) ? 8'd1 : 
							 {3'b111,~mant_sum_shift}),
						.cin((mant_sum[MANTISSAWIDTH-1] && a_sign == 0 && b_sign == 0) || (!mant_sum[MANTISSAWIDTH-1] && a_sign == 1 && b_sign == 1) ? 1'b0 : 1'b1),
						.sum(sum_exp));
	//Undo two's compliment on mantissa when the result is negative.
	adder25 add25_mantsum_neg(.a(~(mant_sum)), .b(25'b0), .cin(1'd1), .sum(mant_sum_neg));
	assign mant_sum_sign = ((in1_sign && in1_mant > in2_mant) || (in2_sign && in1_mant < in2_mant));

	always @(*) begin
		if ((mant_sum[MANTISSAWIDTH-1] && a_sign == 0 && b_sign == 0) || (!mant_sum[MANTISSAWIDTH-1] && a_sign == 1 && b_sign == 1))
			sum_mant <= ((mant_sum_sign) ? mant_sum_neg[MANTISSAWIDTH-1:1] : mant_sum[MANTISSAWIDTH-1:1]);
		else 
			sum_mant <= ((mant_sum_sign) ? {mant_sum_neg} : mant_sum) << mant_sum_shift;
	end

	//Evalute final result
	// assign rslt_sign = (a_sign != b_sign && a_exp == b_exp && a_mant == b_mant) ? 1'd0 : //Special Case Zero
	// 					(a_abs_greater && a_sign) || (!a_abs_greater && b_sign);
	// assign rslt_exp = (a_sign != b_sign && a_exp == b_exp && a_mant == b_mant) ? 8'd0 : sum_exp; //Special Case Zero
	// assign rslt_mant = sum_mant[MANTISSAWIDTH-2:0];

	always @(*) begin 
		if (a == 0) begin 
			rslt_sign = b_sign;
			rslt_exp = b_exp;
			rslt_mant	= b_mant;
		end 
		else if (b == 0) begin 
			rslt_sign = a_sign;
			rslt_exp = a_exp;
			rslt_mant	= a_mant;
		end 
		else if (a_sign != b_sign && a_exp == b_exp && a_mant == b_mant) begin
			rslt_sign = 0;
			rslt_exp = 0;
			rslt_mant = 0;
		end 
		else if (a[WIDTH - 2:0] == 31'h7f800000 || b[WIDTH - 2:0] == 31'h7f800000) begin //either results are +-infinite
			if (a[WIDTH - 2:0] == b[WIDTH - 2:0]) begin
				rslt_sign = (a_sign == b_sign) ? a_sign : 0;
				rslt_exp = a_exp;
				rslt_mant = (a_sign == b_sign) ? a_sign : 23'h7fffff;
			end 
		end
		else begin 
			rslt_sign = (a_abs_greater && a_sign) || (!a_abs_greater && b_sign);
			rslt_exp = sum_exp;
			rslt_mant = sum_mant[MANTISSAWIDTH-2:0];
		end 
	end

	assign sum = {rslt_sign, rslt_exp, rslt_mant};

endmodule //add_f32

module leading_zeroes_25(a, count);
	localparam WIDTH = 24;
	localparam MAX_COUNT_WIDTH = 5;
	// inputs
	input [WIDTH - 1:0] a;
	// outputs
	output [MAX_COUNT_WIDTH - 1:0] count;

	assign count = (a[WIDTH - 1] == 1) ? 0 :
		(a[WIDTH - 1:23] == 0 && a[22] == 1) ? 1 :
		(a[WIDTH - 1:22] == 0 && a[21] == 1) ? 2 :
		(a[WIDTH - 1:21] == 0 && a[20] == 1) ? 3 :
		(a[WIDTH - 1:20] == 0 && a[19] == 1) ? 4 :
		(a[WIDTH - 1:19] == 0 && a[18] == 1) ? 5 :
		(a[WIDTH - 1:18] == 0 && a[17] == 1) ? 6 :
		(a[WIDTH - 1:17] == 0 && a[16] == 1) ? 7 :
		(a[WIDTH - 1:16] == 0 && a[15] == 1) ? 8 :
		(a[WIDTH - 1:15] == 0 && a[14] == 1) ? 9 :
		(a[WIDTH - 1:14] == 0 && a[13] == 1) ? 10 :
		(a[WIDTH - 1:13] == 0 && a[12] == 1) ? 11 :
		(a[WIDTH - 1:12] == 0 && a[11] == 1) ? 12 :
		(a[WIDTH - 1:11] == 0 && a[10] == 1) ? 13 :
		(a[WIDTH - 1:10] == 0 && a[9] == 1) ? 14 :
		(a[WIDTH - 1:9] == 0 && a[8] == 1) ? 15 :
		(a[WIDTH - 1:8] == 0 && a[7] == 1) ? 16 :
		(a[WIDTH - 1:7] == 0 && a[6] == 1) ? 17 :
		(a[WIDTH - 1:6] == 0 && a[5] == 1) ? 18 :
		(a[WIDTH - 1:5] == 0 && a[4] == 1) ? 19 :
		(a[WIDTH - 1:4] == 0 && a[3] == 1) ? 20 :
		(a[WIDTH - 1:3] == 0 && a[2] == 1) ? 21 :
		(a[WIDTH - 1:2] == 0 && a[1] == 1) ? 22 :
		(a[WIDTH - 1:1] == 0 && a[0] == 1) ? 23 :
		24;

endmodule //leading_zeroes_25