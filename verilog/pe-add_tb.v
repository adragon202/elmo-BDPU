module test;

	initial begin
		# 1	a = 64'd 80;
		# 1 b = 64'd 4;
		# 1 cin = 64'd 0;
		# 5 cin = 64'd 1;
		# 10 a = 64'd 4;
		# 10 b = 64'd 80;
		# 10 cin = 64'd 0;

		# 100 $stop;
	end

	/* Pulse input */
	reg [63:0] a = 0;
	reg [63:0] b = 0;
	reg cin = 0;
	wire [63:0] sum;
	wire cout;

	adder64 adder64_1(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

	initial
		$monitor("At time %t, a(%d) + b(%d) + cin(%d) = rslt(%d), cout(%d)",
				$time, a, b, cin, sum, cout);

endmodule //test