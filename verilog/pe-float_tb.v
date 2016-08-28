module test;

	initial begin
		//1
		# 1	asmall = 32'd 80;
		# 0	alarge = 64'd 80;
		//2
		# 1	asmall = 32'd 1;
		# 0	alarge = 64'd 1;
		//3
		# 1	asmall = 32'd 2;
		# 0	alarge = 64'd 2;
		//4
		# 1	asmall = 32'd 3;
		# 0	alarge = 64'd 3;
		//5
		# 1	asmall = 32'd 4;
		# 0	alarge = 64'd 4;
		//6
		# 1	asmall = 32'd 5;
		# 0	alarge = 64'd 5;
		//7
		# 1	asmall = 32'd 6;
		# 0	alarge = 64'd 6;
		//8
		# 1	asmall = 32'd 7;
		# 0	alarge = 64'd 7;
		//9
		# 1	asmall = 32'd 8;
		# 0	alarge = 64'd 8;
		//10
		# 1	asmall = 32'd 9;
		# 0	alarge = 64'd 9;
		//11
		# 1	asmall = 32'h 11E40E0E; //result 0x4d8f2070
		# 0	alarge = 64'h 11E40E0E;
		//12
		# 1	asmall = 32'h 7FFFFFFF; //result 0x4f000000
		# 0	alarge = 64'h 7FFFFFFFFFFFFFFF;
		//13
		# 1	asmall = 32'h FFFFFFFF; //result 0xbf800000
		# 0	alarge = 64'h FFFFFFFFFFFFFFFF;
		//14
		# 1	asmall = 32'h 80000000; //result 0xcf000000
		# 0	alarge = 64'h 8000000000000000;
		//15
		# 1	asmall = -5;
		# 0	alarge = -5;
		//16
		# 1	asmall = -8;
		# 0	alarge = -8;
		//17
		# 1 asmall = 32'd 2147483647; //result 0x4f000000
		# 0 alarge = 64'd 2147483647;

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
		$monitor("At time %t, float32 a(%d) = 0x%h b-sign(%b) b-exponent(%d) b-mantissa(0x%h) power(%d) rem(%d)\n",
				$time, asmall, bfloatsmall, bfloatsmall[31], bfloatsmall[30:23], bfloatsmall[22:0], highpowsmall, highremsmall,
				"At time %t, float64 a(%d) = 0x%h b-sign(%b) b-exp(%d) b-man(0x%h)\npower(%d) rem(%d)",
				$time, alarge, bfloatlarge, bfloatlarge[63], bfloatlarge[62:52], bfloatlarge[51:0], highpowlarge, highremlarge);

endmodule //test