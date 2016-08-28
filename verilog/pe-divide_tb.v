module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 1;
		//clocked at 227 clock cycles sol(0x40000000)
		# 0	a = 32'd4; //0x40800000
		# 0 b = 32'd2; //0x40000000^-1 = 0x3f000000
		# 0 expected_result = 32'h40000000;
		# 0 expected_recip = 32'h3f000000;
		//clocked at 149 clock cycles sol(0x3faaaaab)
		// # 0	a = 32'd4; //0x40800000
		// # 0 b = 32'd3; //0x40400000^-1 = 0x3eaaaaab
		// # 0 expected_result = 32'h3faaaaab;
		// # 0 expected_recip = 32'h3eaaaaab;
		//clocked at 37 clock cycles sol(0x00000000) TODO
		// # 0	a = 32'd0; //0x00000000
		// # 0 b = 32'd2147483646; //0x4effffff^-1 = 0x30000000
		// # 0 expected_result = 32'h00000000;
		// # 0 expected_recip = 32'h30000000;
		//clocked at 2 clock cycles sol(0x7f800000)
		// # 0	a = 32'd2147483646; //0x4effffff
		// # 0 b = 32'd0; //0x00000000^-1 = 0x7f800000
		// # 0 expected_result = 32'h7f800000;
		// # 0 expected_recip = 32'h7f800000;
		// clocked at 37 clock cycles sol(0x3f800000)
		// # 0	a = 32'd2147483646; //0x4effffff
		// # 0 b = 32'd2147483646; //0x4effffff^-1 = 0x30000000
		// # 0 expected_result = 32'h3f800000;
		// # 0 expected_recip = 32'h30000000;
		//clocked at 37 clock cycles sol(0xbf800000)
		// # 0	a = 32'h80000001; //-2147483647
		// # 0 b = 32'h7FFFFFFE; //2147483646^-1 = 0x30000000
		// # 0 expected_result = 32'hbf800000;
		// # 0 expected_recip = 32'h30000000;
		//clocked at 37 clock cycles sol(0xbf800000)
		// # 0	a = 32'h7FFFFFFE; //2147483646
		// # 0 b = 32'h80000001; //-2147483647^-1 = 0xb0000000
		// # 0 expected_result = 32'hbf800000;
		// # 0 expected_recip = 32'hb0000000;
		//clocked at 37 clock cycles sol(0x3f800000)
		// # 0	a = 32'h80000001; //-2147483647 
		// # 0 b = 32'h80000001; //-2147483647^-1 = 0xb0000000
		// # 0 expected_result = 32'h3f800000;
		// # 0 expected_recip = 32'hb0000000;
		//clocked at 69 clock cycles sol(0x353fe1b3)
		// # 0	a = 32'd193; //0x43410000
		// # 0 b = 32'd270000000; //0x4d80befc^-1 = 0x317e843f
		// # 0 expected_result = 32'h353fe1b3;
		// # 0 expected_recip = 32'h317e843f;
		//clocked at 243 clock cycles sol(0x3f000000)
		// # 0	a = 32'd193; //0x43410000
		// # 0 b = 32'd386; //0x43c10000^-1 = 0x3b29c84b
		// # 0 expected_result = 32'h3f000000;
		// # 0 expected_recip = 32'h3b29c84b;
		# 10 rst = 0;
		// # 150 rst = 1;
		// # 20 rst = 0;
		# 1500 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a;
	reg [31:0] b;
	reg [31:0] expected_recip;
	reg [31:0] expected_result;
	wire [31:0] a_float, b_float;
	wire [31:0] recip, acc, result;
	wire recip_out;
	wire rslt_out;

	always
		#5 clk  = !clk;

	int2float32 float32_a(.a(a), .b(a_float));
	int2float32 float32_b(.a(b), .b(b_float));
	recip_f32 recip_f32_1(.clk(clk), .rst(rst), .val(b_float), .rdy(recip_out), .recip(recip), .recip_acc(acc));
	divide_f32 divide_f32_1(.clk(clk), .rst(rst), .num(a_float), .den(b_float), .rdy(rslt_out), .quo(result));

	initial
		$monitor("%g\t(%b)(%b), a(%d)(0x%h) / b(%d)(0x%h) = a * b^-1(?0x%h?)(0x%h) (%b)acc(0x%h) = rslt(?0x%h?)(0x%h) (%b)",
				$time, clk, rst, a, a_float, b, b_float, expected_recip, recip, recip_out, acc, expected_result, result, rslt_out);

endmodule //test