
/*
Uses approximation method
#1. Set den to 2
#2. a/den = result (float)
#3. if den == result then DONE
#4. mean(den,result,mn) (float)
#5. set den = mn
#6. Repeat from step 2
INPUTS:
	a = Number to find Square Root for
OUTPUTS:
	sqrt = Square Root of input
*/
module squareroot(clk, a, sqrt);
	//input declaration
	input [63:0] a;
	//output declaration
	output [63:0] sqrt;
	//port data types
	wire [63:0] a, sqrt;
	reg [63:0] den, result, mn;
	//code starts here
	divide D1(a,den,result);
	mean M1(den,result,mn);
	always @ (posedge clk)
	begin
		mn = 64'd 2;
		den = 0;
		result = 9999;
		while (den != result) begin
			den = mn;
		end
		sqrt <= result;
	end

endmodule //squareroot

/*
Performs operation dvd=a/b in floating point
INPUTS:
	a = numerator
	b = denominator
OUTPUTS:
	dvd = dividend
*/
module divide(a, b, dvd);
	//input declaration
	input [63:0] a, b; 
	//output declaration;
	output [63:0] dvd;
	//port data types
	wire [63:0] a, b, dvd;
	//code starts here
	assign dvd = a / b;

endmodule //divide
