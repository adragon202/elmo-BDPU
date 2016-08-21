module test;
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;

	initial begin
		// 1.5 + 0.25 = 1.75 (1071644672)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 125;
		# 0 b_mant = 23'd 0;
		// 1.5 - 0.25 = 1.25 (1067450368)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 125;
		# 0 b_mant = 23'd 0;
		// 1.5 + 2.5 = 4 (1082130432)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 128;
		# 0 b_mant = 23'd 2097152;
		// 1.5 - 2.5 = -1 (3212836864)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 128;
		# 0 b_mant = 23'd 2097152;
		// 20.8 + 1.2 = 22 (1102053376)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;
		// 20.8 - 1.2 = 19.6 (1100795085)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;
		// -20.8 - 1.2 = -22 (3249537024)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;

		# 10 $stop;
	end

	/* Pulse input */
	reg a_sign = 0;
	reg [EXPONENTWIDTH - 1:0] a_exp = 8'd127;
	reg [MANTISSAWIDTH - 1:0] a_mant = 23'd6000;
	wire [WIDTH - 1:0] a = {a_sign, a_exp, a_mant}; //1.0007153
	reg b_sign = 0;
	reg [EXPONENTWIDTH - 1:0] b_exp = 8'd127;
	reg [MANTISSAWIDTH - 1:0] b_mant = 23'd500;
	wire [WIDTH - 1:0] b = {b_sign, b_exp, b_mant}; //1.0000596
	wire [WIDTH - 1:0] sum;
	wire a_greater;
	wire [EXPONENTWIDTH - 1:0] exp_diff;
	wire [EXPONENTWIDTH - 1:0] rsltexp;
	wire [MANTISSAWIDTH - 1:0] rsltmant;
	wire [MANTISSAWIDTH - 1:0] prersltmant;
	wire [MANTISSAWIDTH - 1:0] in1_mant;
	wire [MANTISSAWIDTH - 1:0] in2_mant;

	add_f32 add_f32_1(.a(a), .b(b), .sum(sum)
		, .a_greater(a_greater), .exp_diff(exp_diff), .sum_exp(rsltexp), .sum_mant(rsltmant)
		, .mant_sum(prersltmant), .out1_mant(in1_mant), .out2_mant(in2_mant));

	initial
		$monitor("At time a(%h)(%d %d %h) + b(%h)(%d %d %h) = rslt(%h) a_great(%d) expdiff(%d) exp(%d) mant(%h)(%h)(%h)(%h)",
				a, a_sign, a_exp, a_mant, b, b_sign, b_exp, b_mant, sum, a_greater, exp_diff, rsltexp, rsltmant, prersltmant, in1_mant, in2_mant);

endmodule //test