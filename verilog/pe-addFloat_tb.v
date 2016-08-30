module test;
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;

	initial begin
		// 01, 1.5 + 0.25 = 1.75 (1071644672)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 125;
		# 0 b_mant = 23'd 0;
		// 02, 1.5 - 0.25 = 1.25 (1067450368)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 125;
		# 0 b_mant = 23'd 0;
		// 03, 1.5 + 2.5 = 4 (1082130432)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 128;
		# 0 b_mant = 23'd 2097152;
		// 04, 1.5 - 2.5 = -1 (3212836864)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 127;
		# 0	a_mant = 23'd 4194304;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 128;
		# 0 b_mant = 23'd 2097152;
		// 05, 20.8 + 1.2 = 22 (1102053376)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;
		// 06, 20.8 - 1.2 = 19.6 (1100795085)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;
		// 07, -20.8 - 1.2 = -22 (3249537024)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd 131;
		# 0	a_mant = 23'd 2516582;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd 127;
		# 0 b_mant = 23'd 1677722;
		// 08, -500.12 + 500.12 = 0 (0)
		# 1	a_sign	= 1;
		# 0	a_exp	= 8'd 135;
		# 0	a_mant	= 23'd 7999324;
		# 0	b_sign	= 0;
		# 0	b_exp	= 8'd 135;
		# 0	b_mant	= 23'd 7999324;
		// 09, 500.12 - 500.12 = 0 (0)
		# 1	a_sign	= 0;
		# 0	a_exp	= 8'd 135;
		# 0	a_mant	= 23'd 7999324;
		# 0	b_sign	= 1;
		# 0	b_exp	= 8'd 135;
		# 0	b_mant	= 23'd 7999324;
		// 10, -500.12 + 700.12 = 200 (43480000)	
		# 1	a_sign	= 1;
		# 0	a_exp	= 8'd 135;
		# 0	a_mant	= 23'd 7999324;
		# 0	b_sign	= 0;
		# 0	b_exp	= 8'd 136;
		# 0	b_mant	= 23'd 3082158;
		// 11, 700.12 - 500.12 = 200 (43480000)
		# 1	a_sign	= 0;
		# 0	a_exp	= 8'd 136;
		# 0	a_mant	= 23'd 3082158;
		# 0	b_sign	= 1;
		# 0	b_exp	= 8'd 135;
		# 0	b_mant	= 23'd 7999324;
		// 12, 0 + 0 = 0 (0x0)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd 0;
		# 0	a_mant = 23'd0;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd0;
		# 0 b_mant = 23'd0;
		// 13, 5 + 0 = 5 (0x40a00000)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd129;
		# 0	a_mant = 23'd2097152;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd0;
		# 0 b_mant = 23'd0;
		// 14, 0 - 6 = -6 (0x40c00000)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd129;
		# 0	a_mant = 23'd4194304;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd0;
		# 0 b_mant = 23'd0;
		// 15, 1.25 - 1 = 0.25 (0x3e800000)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd127;
		# 0	a_mant = 23'd2097152;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd127;
		# 0 b_mant = 23'd0;
		// 16, -1.25 + 1 = -0.25 (0xbe800000)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd127;
		# 0	a_mant = 23'd2097152;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd127;
		# 0 b_mant = 23'd0;
		// 17, 0.24491003 + 0.2570581 = 0.50196815 (0x3f0080fc)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd124;
		# 0	a_mant = 23'd8047026;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd125;
		# 0 b_mant = 23'd236831;
		// 18, 0.9398058	- 0.1159356976 = 0.8238701024 (0x3f52e927)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd126;
		# 0	a_mant = 23'd7378717;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd123;
		# 0 b_mant = 23'd7172018;
		// 19, 4.98086	+ 0.2821059162 = 5.2629659162 (0x40a86a37)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd129;
		# 0	a_mant = 23'd2057013;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd125;
		# 0 b_mant = 23'd1077296;
		// 20, 785.7069876	- 30.88526349 = 754.82172411 (0x443cb497)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd136;
		# 0	a_mant = 23'd4484415;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd131;
		# 0 b_mant = 23'd7804165;
		// 21, 6.8311649E9	- 1.34663962E9 = 5.4845251E9 (0x4fa3739b)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd159;
		# 0	a_mant = 23'd4953511;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd157;
		# 0 b_mant = 23'd2132014;
		// 22, 4.9249485E9 - 0.9940168 = 4.9249485E9 (0x4f92c660)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd159;
		# 0	a_mant = 23'd1230432;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd126;
		# 0 b_mant = 23'd8288227;
		// 23, 0.5747798 -	7339695.0 = -7339694.42522 (0xcadffd5d)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd126;
		# 0	a_mant = 23'd1254597;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd149;
		# 0 b_mant = 23'd6290782;
		// 24, -0.84127694 - 0.7590595 = -1.6003364 (0xbfccd7d3)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd126;
		# 0	a_mant = 23'd5725677;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd126;
		# 0 b_mant = 23'd4346297;
		// 25, 0.26604247	- 0.26604247 = 0 (0x00000000)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd125;
		# 0	a_mant = 23'd538296;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd125;
		# 0 b_mant = 23'd538296;
		// 26, -288.4304631 - 778.925073 = -1067.3556(0xc4856b61)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd135;
		# 0	a_mant = 23'd1062681;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd136;
		# 0 b_mant = 23'd4373300;
		// 27, -3.55458611E9	- 5.8136832E9 = -9.3682688E9 (0xd00b991c)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd158;
		# 0	a_mant = 23'd5496494;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd159;
		# 0 b_mant = 23'd2966242;
		// 28, NaN			+ 0				= NaN			(7fffffff) (255) (8388607)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd255;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd0;
		# 0 b_mant = 23'd0;
		// 29, 0			+ NaN			= NaN			(7fffffff) (255) (8388607)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd0;
		# 0	a_mant = 23'd0;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd255;
		# 0 b_mant = 23'd8388607;
		// 30, 28.382		+ NaN			= NaN			(7fffffff) (255) (8388607)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd131;
		# 0	a_mant = 23'd6491734;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd255;
		# 0 b_mant = 23'd8388607;
		// 31, NaN			+ infinity		= NaN			(7fffffff)X (255) (8388607)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd255;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd255;
		# 0 b_mant = 23'd0;
		// 32, 0			+ infinity		= infinity		(7f800000) (255) (0000000)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd0;
		# 0	a_mant = 23'd0;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd255;
		# 0 b_mant = 23'd0;
		// 33, 3.4028235E38+ 2.3509886E-38	= 3.4028235e+38 (7f7fffff) 
		# 1	a_sign = 0;
		# 0	a_exp = 8'd254;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd1;
		# 0 b_mant = 23'd8388607;
		// 34, 3.4028235E38- 2.3509886E-38	= 3.4028235e+38 (7f7fffff) 
		# 1	a_sign = 0;
		# 0	a_exp = 8'd254;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd1;
		# 0 b_mant = 23'd8388607;
		// 35, -3.4028235E38+ 2.3509886E-38= -3.4028235e+38(ff7fffff) 
		# 1	a_sign = 1;
		# 0	a_exp = 8'd254;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd1;
		# 0 b_mant = 23'd8388607;
		// 36, -3.4028235E38- 2.3509886E-38= -3.4028235e+38(ff7fffff) 
		# 1	a_sign = 1;
		# 0	a_exp = 8'd254;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd1;
		# 0 b_mant = 23'd8388607;
		// 37, 2.3509886E-38+ 3.4028235E38	= 3.4028235e+38 (7f7fffff)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd1;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd254;
		# 0 b_mant = 23'd8388607;
		// 38, 2.3509886E-38- 3.4028235E38	= -3.4028235e+38(ff7fffff)
		# 1	a_sign = 0;
		# 0	a_exp = 8'd1;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd254;
		# 0 b_mant = 23'd8388607;
		// 39, -2.3509886E-38+ 3.4028235E38= 3.4028235e+38 (7f7fffff) 
		# 1	a_sign = 1;
		# 0	a_exp = 8'd1;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 0;
		# 0 b_exp = 8'd254;
		# 0 b_mant = 23'd8388607;
		// 40, -2.3509886E-38- 3.4028235E38= -3.4028235e+38(ff7fffff)
		# 1	a_sign = 1;
		# 0	a_exp = 8'd1;
		# 0	a_mant = 23'd8388607;
		# 0 b_sign = 1;
		# 0 b_exp = 8'd254;
		# 0 b_mant = 23'd8388607;
		
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
	wire [EXPONENTWIDTH - 1:0] exp_diff;
	wire [EXPONENTWIDTH - 1:0] rsltexp;
	wire [EXPONENTWIDTH - 1:0] prersltexp;
	wire [4:0] mant_shift;
	wire [MANTISSAWIDTH - 1:0] rsltmant;
	wire [MANTISSAWIDTH:0] prersltmant;
	wire [MANTISSAWIDTH:0] in1_mant;
	wire [MANTISSAWIDTH:0] in2_mant;

	add_f32 add_f32_1(.a(a), .b(b), .sum(sum)
		, .exp_diff(exp_diff), .sum_exp(rsltexp), .in_exp(prersltexp), .sum_mant({X,Y,rsltmant})
		, .mant_sum({X,prersltmant}), .out1_mant({X,in1_mant}), .out2_mant({X,in2_mant}), .mant_sum_shift(mant_shift));

	initial
		$monitor("At time a(%h)(%d %d %h) + b(%h)(%d %d %h) = rslt(%h) expdiff(%d) exp(%d)(%d) mantshift(%d) mant(%h)(%h)(%h)(%h)",
				a, a_sign, a_exp, a_mant, b, b_sign, b_exp, b_mant, sum, exp_diff, rsltexp, prersltexp, mant_shift, rsltmant, prersltmant, in1_mant, in2_mant);

endmodule //test