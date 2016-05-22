module test;

	initial begin
		# 1	num = 64'd 80;
		# 1 den = 64'd 4;
		# 100 $stop;
	end

	/* Make a regular pulsing clock. */
	// reg clk = 0;
	// always #5 clk = !clk;

	/* Pulse input */
	reg [63:0] num = 0;
	reg [63:0] den = 0;

	wire real [63:0] numf;
	wire real [63:0] denf;
	wire [63:0] value;
	int2float i2f_1(num,numf);
	int2float i2f_2(den,denf);
	dividefloat divf_1(numf,denf,value);

	initial
		$monitor("At time %t, num(%d) / den(%d) = rslt(%d)",
				$time, num, den, value);

endmodule //test