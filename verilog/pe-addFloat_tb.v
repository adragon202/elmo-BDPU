module test;

	initial begin
		# 1	a = 32'd 80;
		# 1 b = 32'd 4;
		# 1 cin = 32'd 0;
		# 1 cin = 32'd 1;
		# 1 a = 32'd 4;
		# 1 b = 32'd 80;
		# 1 cin = 32'd 0;

		# 100 $stop;
	end

	/* Pulse input */
	reg [63:0] a = 0;
	reg [63:0] b = 0;
	reg cin = 0;
	wire [63:0] sum;
	wire cout;

	add_f32 add_f32_1(.a(a), .b(b), .sum(sum));

	initial
		$monitor("At time %t, a(%d) + b(%d) + cin(%d) = rslt(%d), cout(%d)",
				$time, a, b, cin, sum, cout);

endmodule //test