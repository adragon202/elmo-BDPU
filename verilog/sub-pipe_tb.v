module test;

	initial begin
		//extreme test values
		// # 0 a[0]	= 32'h0; b[0]	= 32'h0; rslt_expected[0]	= 32'h0;
		// # 0 a[1]	= 32'h80000000; b[1]	= 32'h80000000; rslt_expected[1]	= 32'h5f800000; //Errors to 4 due to unsigned overflow
		// # 0 a[2]	= 32'h7FFFFFFF; b[2]	= 32'h7FFFFFFF; rslt_expected[2]	= 32'h5f800000; //Errors to 4 due to unsigned overflow
		// # 0 a[3]	= 32'h0; b[3]	= 32'h0; rslt_expected[3]	= 32'h0;
		// # 0 a[4]	= 32'h0; b[4]	= 32'h0; rslt_expected[4]	= 32'h0;
		// # 0 a[5]	= 32'h0; b[5]	= 32'h0; rslt_expected[5]	= 32'h0;
		// # 0 a[6]	= 32'h0; b[6]	= 32'h0; rslt_expected[6]	= 32'h0;
		// # 0 a[7]	= 32'h0; b[7]	= 32'h0; rslt_expected[7]	= 32'h0;
		// # 0 a[8]	= 32'h0; b[8]	= 32'h0; rslt_expected[8]	= 32'h0;
		// # 0 a[9]	= 32'h0; b[9]	= 32'h0; rslt_expected[9]	= 32'h0;
		// # 0 a[10]	= 32'h0; b[10]	= 32'h0; rslt_expected[10]	= 32'h0;
		// # 0 a[11]	= 32'h0; b[11]	= 32'h0; rslt_expected[11]	= 32'h0;
		// # 0 a[12]	= 32'h0; b[12]	= 32'h0; rslt_expected[12]	= 32'h0;
		// # 0 a[13]	= 32'h0; b[13]	= 32'h0; rslt_expected[13]	= 32'h0;
		// # 0 a[14]	= 32'h0; b[14]	= 32'h0; rslt_expected[14]	= 32'h0;
		// # 0 a[15]	= 32'h0; b[15]	= 32'h0; rslt_expected[15]	= 32'h0;
		//pipe workable values
		# 0 a[0]	= 32'h00000011; b[0]	= 32'h0000000C; rslt_expected[0]	= 32'h44524000; //17 + 12 		=> 841
		# 0 a[1]	= 32'hFFFFFFEF; b[1]	= 32'h0000000C; rslt_expected[1]	= 32'h41c80000; //-17 + 12 		=> 25
		# 0 a[2]	= 32'h00000011; b[2]	= 32'hFFFFFFF4; rslt_expected[2]	= 32'h41c80000; //17 - 12 		=> 25
		# 0 a[3]	= 32'hFFFFFFEF; b[3]	= 32'hFFFFFFF4; rslt_expected[3]	= 32'h44524000; //-17 - 12 		=> 841
		# 0 a[4]	= 32'h00007530; b[4]	= 32'h000000C8; rslt_expected[4]	= 32'h4e597281; //30000 + 200 	=> 912040000
		# 0 a[5]	= 32'hFFFF8AD0; b[5]	= 32'h000000C8; rslt_expected[5]	= 32'h4e53b9a9; //-30000 + 200 	=> 888040000
		# 0 a[6]	= 32'h00007530; b[6]	= 32'hFFFFFF38; rslt_expected[6]	= 32'h4e53b9a9; //30000 - 200 	=> 888040000
		# 0 a[7]	= 32'hFFFF8AD0; b[7]	= 32'hFFFFFF38; rslt_expected[7]	= 32'h4e597281; //-30000 - 200 	=> 912040000
		# 0 a[8]	= 32'h000002AA; b[8]	= 32'h0001863C; rslt_expected[8]	= 32'h5016c04c; //682 + 99900 	=> 10116738720
		# 0 a[9]	= 32'hFFFFFD56; b[9]	= 32'h0001863C; rslt_expected[9]	= 32'h5012b0b0; //-682 + 99900 	=> 9844211524
		# 0 a[10]	= 32'h000002AA; b[10]	= 32'hFFFE79C4; rslt_expected[10]	= 32'h5012b0b0; //682 - 99900 	=> 9844211524
		# 0 a[11]	= 32'hFFFFFD56; b[11]	= 32'hFFFE79C4; rslt_expected[11]	= 32'h5016c04c; //-682 - 99900 	=> 10116738720
		# 0 a[12]	= 32'h0000028A; b[12]	= 32'h00000279; rslt_expected[12]	= 32'h49c8f048; //650 + 633 	=> 1646089
		# 0 a[13]	= 32'hFFFFFD76; b[13]	= 32'h00000279; rslt_expected[13]	= 32'h42440000; //-650 + 633 	=> 49
		# 0 a[14]	= 32'h0000028A; b[14]	= 32'hFFFFFD87; rslt_expected[14]	= 32'h42440000; //650 - 633 	=> 49
		# 0 a[15]	= 32'hFFFFFD76; b[15]	= 32'hFFFFFD87; rslt_expected[15]	= 32'h49c8f048; //-650 - 633 	=> 1646089
		# 0 en = 0;
		# 10 en = 1;
		# 10 en = 0;
		# 10 en = 1;
		# 10 $stop;
	end

	/* Pulse input */
	reg en;
	reg [31:0] a[0:15];
	reg [31:0] b[0:15];
	reg [31:0] rslt_expected [0:15];
	wire [31:0] rslt [0:15];

	pipes_sumsquare pipes_1(.EN(en),
		.vals0({a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15]}), 
		.vals1({b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11],b[12],b[13],b[14],b[15]}), 
		.pipeout({rslt[0],rslt[1],rslt[2],rslt[3],rslt[4],rslt[5],rslt[6],rslt[7],rslt[8],rslt[9],rslt[10],rslt[11],rslt[12],rslt[13],rslt[14],rslt[15]})
		);

	initial
		$monitor("%g\t en(%b), 0((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				$time, en, a[0], b[0], rslt_expected[0], rslt[0],
				"\t en(%b), 1((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[1], b[1], rslt_expected[1], rslt[1],
				"\t en(%b), 2((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[2], b[2], rslt_expected[2], rslt[2],
				"\t en(%b), 3((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[3], b[3], rslt_expected[3], rslt[3],
				"\t en(%b), 4((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[4], b[4], rslt_expected[4], rslt[4],
				"\t en(%b), 5((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[5], b[5], rslt_expected[5], rslt[5],
				"\t en(%b), 6((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)\n",
				en, a[6], b[6], rslt_expected[6], rslt[6],
				"\t en(%b), 7((0x%h)+(0x%h))^2 = ?(0x%h)? (0x%h)",
				en, a[7], b[7], rslt_expected[7], rslt[7]);

endmodule //test