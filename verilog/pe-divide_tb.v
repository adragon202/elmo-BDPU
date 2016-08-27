module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 1;
		# 0	a = 32'd193;
		# 0 b = 32'd2700000000;
		# 10 rst = 0;
		// # 150 rst = 1;
		// # 20 rst = 0;
		# 1000 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a;
	reg [31:0] b;
	wire [31:0] a_float, b_float;
	wire [31:0] recip, result;
	wire recip_out;
	wire rslt_out;

	always
		#5 clk  = !clk;

	int2float32 float32_a(.a(a), .b(a_float));
	int2float32 float32_b(.a(b), .b(b_float));
	recip_f32 recip_f32_1(.clk(clk), .rst(rst), .val(b_float), .rdy(recip_out), .recip(recip));
	divide_f32 divide_f32_1(.clk(clk), .rst(rst), .num(a_float), .den(b_float), .rdy(rslt_out), .quo(result));

	initial
		$monitor("%g\t(%b)(%b), a(%d)(%h) / b(%d)(%h) = a * b^-1(%h)(%b) = (%b) rslt(%h)",
				$time, clk, rst, a, a_float, b, b_float, recip, recip_out, rslt_out, result);

endmodule //test