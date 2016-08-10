module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 0;
		# 0	a = 32'd 1;
		# 0 b = 32'd 4;
		# 6 a = 32'd 4;
		# 0 rst = 1;
		# 0 b = 32'd 1;
		# 20 rst = 0;
		# 100 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a;
	reg [31:0] b;
	wire [31:0] a_float, b_float;
	wire [31:0] result;
	wire val_out;

	always
		#5 clk  = !clk;

	int2float32 float32_a(.a(a), .b(a_float));
	int2float32 float32_b(.a(b), .b(b_float));
	divide_f32 divide_f32_1(.num(a_float), .den(b_float), .quo(result));
	recip_f32 recip_f32_1(.clk(clk), .rst(rst), .val(a_float), .rdy(val_out), .recip(result));

	initial
		$monitor("%g\t(%b)(%b), a(%d) / b(%d) = (%b) rslt(%b)",
				$time, clk, rst, a, b, val_out, result);

endmodule //test