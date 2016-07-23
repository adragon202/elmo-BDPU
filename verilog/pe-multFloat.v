
/*
m = a * b
Multiplies 32-bit floating point values
Mantissas of 32-bit floating point are 23 bits
Exponents of 32-bit floating point are 8 bits
INPUTS:
	a = 32 bits
	b = 32 bits
OUTPUTS:
	m = 32 bits
*/
module mult_float(a,b,m);
	// inputs 
	input [31:0] a, b;
	// outputs
	output [31:0] m;
	// internal wires
	wire [31:0] mult;
	wire [47:0] mantissa, mant_norm;
	wire [23:0] mantA, mantB;
	wire [7:0] ex, ex_sum;
	wire norm, zero_test;

	assign mantA[22:0] = a[22:0];	// mantissa of a
	assign mantA[23] = 1;			// add leading 1

	assign mantB[22:0] = b[22:0];	// mantissa of b
	assign mantB[23] = 1;			// add leading 1
	 
	mult24 mult0(.a(mantA), .b(mantB), .mult(mantissa));	// multiply mantissas

	// add exponents
	adder8 add0(.a(a[30:23]), .b(b[30:23]), .cin(1'b0), .sum(ex_sum), .cout());
	// subtract bias from exponent
	adder8 sub0(.a(ex_sum), .b(8'h81), .cin(1'b0), .sum(ex), .cout());

	// if most significant bit of mantissa is 1, then the float needs to be normalized
	assign norm = mantissa[47];
	  
	// if norm == 0, don't normalize float
	// if norm == 1, shift mantissa to the left, add 1 to exponent
	assign mant_norm = mantissa >> 1;
	mux23 m0(.a(mantissa[45:23]), .b(mant_norm[45:23]), .switch(norm), .out(mult[22:0]));
	adder8 add1(.a(ex), .b({7'd0,norm}), .cin(1'b0), .sum(mult[30:23]), .cout());	// normalize exponent

	xor calc_sign(mult[31], a[31], b[31]);	// handle sign

	// if either a or b is zero, output = zero
	assign zero_test = ((a==32'd0) || (b==32'd0));
	mux32 m1(.a(mult), .b(32'd0), .switch(zero_test), .out(m));	// if zero_test is 1, output is zero

endmodule //mult_float
