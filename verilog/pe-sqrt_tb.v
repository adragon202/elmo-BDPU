module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 1;
		// sqrt(2) = 1.412135 (0x3fb504f3)
		# 0	a = 32'h40000000;
		# 0 sol = 32'h3fb504f3;
		// sqrt(3) = 1.7320508 (0x3fddb3d7)
		// # 1 a = 32'h40400000;
		// # 0 sol = 32'h3fddb3d7;
		# 8 rst = 0;
		# 100000 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a = 0;
	reg [31:0] sol = 0;
	wire [31:0] sqrt;
	wire [31:0] curr_den;
	wire [31:0] curr_div_rslt;
	wire [31:0] curr_result;
	wire [31:0] curr_mean;
	wire sqrt_rdy;

	always
		#5 clk  = !clk;

	squareroot_f32_approximation sqrtf32(.clk(clk), .rst(rst), .a(a), .rdy(sqrt_rdy), .sqrt(sqrt),
										.den(curr_den), .divide_result(curr_div_rslt),
										.result(curr_result), .mn(curr_mean));
	initial
		$monitor("%g\t rst(%b) sqrt(0x%h) = (?0x%h?) (0x%h) rdy(%b) 0x%h/0x%h=0x%h mean(0x%h,0x%h)=0x%h",
				$time, rst, a, sol, sqrt, sqrt_rdy, a, curr_den, curr_div_rslt,
				curr_den, curr_result, curr_mean);

endmodule //test