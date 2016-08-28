module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 1;
		//clocked at 227 clock cycles sol(0x40000000)
		// # 0	a = 32'd4; //0x40800000
		// # 0 b = 32'd2; //0x40000000^-1 = 0x3f000000
		//clocked at 149 clock cycles sol(0x3faaaaab)
		// # 0	a = 32'd4; //0x40800000
		// # 0 b = 32'd3; //0x40400000^-1 = 0x3eaaaaab
		//clocked at unknown clock cycles sol(0x00000000) TODO
		# 0	a = 32'd0; //0x00000000
		# 0 b = 32'd2147483647; //0x4f000000^-1 = 0x30000000
		//clocked at unknown clock cycles sol(0x7f800000) TODO
		// # 0	a = 32'd2147483647; //0x4f000000
		// # 0 b = 32'd0; //0x00000000^-1 = 0x7f800000
		//clocked at unknown clock cycles sol(0x3f800000) TODO
		// # 0	a = 32'd2147483647; //0x4f000000
		// # 0 b = 32'd2147483647; //0x4f000000^-1 = 0x30000000 //Doesn't convert correctly in int2float32(0xXxxxxxxx)
		//clocked at unknown clock cycles sol(0xbf800000) TODO
		// # 0	a = 32'h80000001; //-2147483647
		// # 0 b = 32'h7FFFFFFF; //2147483647^-1 = 
		//clocked at unknown clock cycles sol(0xbf800000) TODO
		// # 0	a = 32'h7FFFFFFF; //2147483647
		// # 0 b = 32'h80000001; //-2147483647^-1 = 
		//clocked at unknown clock cycles sol(0x3f800000) TODO
		// # 0	a = 32'h80000001; //2147483647
		// # 0 b = 32'h80000001; //-2147483647^-1 = 
		//clocked at unknown clock cycles sol(0x3399815c) TODO
		// # 0	a = 32'd193; //0x43410000
		// # 0 b = 32'd2700000000; //0x4f20eebb^-1 = 0x2fcb9cff //Doesn't convert correctly in int2float32(0xcebe228a)
		//clocked at 293 clock cycles sol(0x3f000000)
		// # 0	a = 32'd193; //0x43410000
		// # 0 b = 32'd386; //0x43c10000^-1 = 0x3b29c84b
		# 10 rst = 0;
		// # 150 rst = 1;
		// # 20 rst = 0;
		# 1500 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a;
	reg [31:0] b;
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
		$monitor("%g\t(%b)(%b), a(%d)(0x%h) / b(%d)(0x%h) = a * b^-1(0x%h)(%b)(0x%h) = (%b) rslt(0x%h)",
				$time, clk, rst, a, a_float, b, b_float, recip, recip_out, acc, rslt_out, result);

endmodule //test