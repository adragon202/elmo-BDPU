module test;

	initial begin
		# 0 clk = 0;
		# 0 rst = 1;
		// sqrt(2) = 1.412135 (0x3fb504f3)
		// clocked at 13 cycles
		# 0	a = 32'h40000000;
		# 0 sol = 32'h3fb504f3;
		// sqrt(3) = 1.7320508 (0x3fddb3d7)
		// clocked at 18 cycles
		// # 0 a = 32'h40400000;
		// # 0 sol = 32'h3fddb3d7;
		// sqrt(2087.536) = 45.68956 (0x4236c21c)
		// clocked at 12 cycles
		// # 0 a = 32'h45027893;
		// # 0 sol = 32'h4236c21c;
		// sqrt(0) = 0 (0x00000000)
		// clocked at 2 cycles
		// # 0 a = 32'h00000000;
		// # 0 sol = 32'h00000000;
		// sqrt(Infinity) = Infinity (0x7f800000)
		// clocked at 2 cycles
		// # 0 a = 32'h7f800000;
		// # 0 sol = 32'h7f800000;
		// sqrt(NaN) = NaN (0x7fffffff)
		// clocked at 2 cycles
		// # 0 a = 32'h7fffffff;
		// # 0 sol = 32'h7fffffff;
		// sqrt(1) = 1 (0x3f800000)
		// clocked at 2 cycles
		// # 0 a = 32'h3f800000;
		// # 0 sol = 32'h3f800000;
		// sqrt(-1) = -1 (0xbf800000)
		// clocked at unknown cycles //TODO: WRONG MANTISSA. -1.9999999 (0xbfffffff)
		// # 0 a = 32'hbf800000;
		// # 0 sol = 32'hbf800000;
		// sqrt(-2) = -1.412135 (0xbfb504f3)
		// clocked at unknown cycles //TODO: WRONG MANTISSA. -1.9999999 (0xbfffffff)
		// # 0 a = 32'hc0000000;
		// # 0 sol = 32'hbfb504f3;
		// sqrt(1.5) = 1.2247449 (0x3f9cc471)
		// clocked at 11 cycles
		// # 0 a = 32'h3fc00000;
		// # 0 sol = 32'h3f9cc471;
		// sqrt(0.128539674) = 0.35852430043 (0x3eb7907f)
		// clocked at 9 cycles //TODO: Off by 1. 0.35852432 (0x3eb79080)
		// # 0 a = 32'h3e039fe8;
		// # 0 sol = 32'h3eb7907f;
		// sqrt(1.4E-45) = 3.7416575E-23 (0x1a34ef7a)
		// clocked at unknown cycles //TODO: NEVER FINISHED. Stuck at 5.421011E-20 (0x1f800000)
		// # 0 a = 32'h00000001;
		// # 0 sol = 32'h1a34ef7a;
		// sqrt(2.8E-45) = 5.2915026e-23 (0x1a7fe1a1)
		// clocked at unknown cycles //TODO: NEVER FINISHED. Stuck at 5.421011E-20 (0x1f800000)
		// # 0 a = 32'h00000002;
		// # 0 sol = 32'h1a7fe1a1;
		// sqrt(3.4028235E38) = 1.8446744E19 (0x5f800000)
		// clocked at unknown cycles //TODO: Off by 1. 1.8446743E19 (0x5f7fffff)
		// # 0 a = 32'h7f7fffff;
		// # 0 sol = 32'h5f800000;
		// sqrt(3.3.4028233E38) = 1.8446743E19 (0x5f7fffff)
		// clocked at 24 cycles
		// # 0 a = 32'h7f7ffffe;
		// # 0 sol = 32'h5f7fffff;
		// sqrt(0.5) = 0.70710677 (0x3f3504f3)
		// clocked at 13 cycles
		// # 0 a = 32'h3f000000;
		// # 0 sol = 32'h3f3504f3;
		# 8 rst = 0;
		# 500 $stop;
	end

	/* Pulse input */
	reg clk, rst;
	reg [31:0] a = 0;
	reg [31:0] sol = 0;
	wire [31:0] sqrt;

	always
		#5 clk  = !clk;

	squareroot_f32 sqrtf32(.clk(clk), .rst(rst), .a(a), .rdy(sqrt_rdy), .sqrt(sqrt));
	initial
		$monitor("%g\t rst(%b) sqrt(0x%h) = (?0x%h?) (0x%h) rdy(%b)",
				$time, rst, a, sol, sqrt, sqrt_rdy);

endmodule //test