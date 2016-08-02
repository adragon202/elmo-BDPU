module test;

	initial begin
		# 1	asmall = 32'd 80;
		# 0	alarge = 64'd 80;
		# 1	asmall = 32'd 1;
		# 0	alarge = 64'd 1;
		# 1	asmall = 32'd 2;
		# 0	alarge = 64'd 2;
		# 1	asmall = 32'd 3;
		# 0	alarge = 64'd 3;
		# 1	asmall = 32'd 4;
		# 0	alarge = 64'd 4;
		# 1	asmall = 32'd 5;
		# 0	alarge = 64'd 5;
		# 1	asmall = 32'd 6;
		# 0	alarge = 64'd 6;
		# 1	asmall = 32'd 7;
		# 0	alarge = 64'd 7;
		# 1	asmall = 32'd 8;
		# 0	alarge = 64'd 8;
		# 1	asmall = 32'd 9;
		# 0	alarge = 64'd 9;
		# 1	asmall = 32'd 300158478;
		# 0	alarge = 64'd 300158478;
		# 1	asmall = -1;
		# 0	alarge = -1;
		# 1	asmall = -5;
		# 0	alarge = -5;
		# 1	asmall = -8;
		# 0	alarge = -8;

		# 10 $stop;
	end

	/* Pulse input */
	reg [31:0] asmall = 0;
	wire [31:0] bfloatsmall;
	wire [7:0] highpowsmall;
	wire [31:0] highremsmall;
	reg [63:0] alarge = 0;
	wire [63:0] bfloatlarge;
	wire [10:0] highpowlarge;
	wire [63:0] highremlarge;

	int2float32 float32_1(.a(asmall), .b(bfloatsmall));
	highestpower32 pow32_1(.a(asmall), .b(highpowsmall), .rem(highremsmall));
	int2float64 float64_1(.a(alarge), .b(bfloatlarge));
	highestpower64 pow64_1(.a(alarge), .b(highpowlarge), .rem(highremlarge));
	initial
		$monitor("At time %t, float32 a(%d) = b-sign(%b) b-exponent(%b) b-mantissa(%b) power(%d) rem(%d)\n",
				$time, asmall, bfloatsmall[31], bfloatsmall[30:23], bfloatsmall[22:0], highpowsmall, highremsmall,
				"At time %t, float64 a(%d) = b-sign(%b) b-exp(%b) b-man(%b)\npower(%d) rem(%d)",
				$time, alarge, bfloatlarge[63], bfloatlarge[62:52], bfloatlarge[51:0], highpowlarge, highremlarge);

endmodule //test