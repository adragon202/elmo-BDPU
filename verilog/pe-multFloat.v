
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
module mult_f32(a,b,m);
	// definitions
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	localparam MANTISSAOVERFLOW = 47;
	localparam EXPONENTBIAS = 127;
	// inputs 
	input [WIDTH - 1:0] a, b;
	// outputs
	output [WIDTH - 1:0] m;
	// internal wires
	wire [WIDTH - 1:0] mult;
	wire [MANTISSAOVERFLOW:0] mult_mant, mult_mantnorm;
	wire a_sign, b_sign;
	wire [EXPONENTWIDTH - 1:0] a_exp, b_exp;
	wire [MANTISSAWIDTH:0] a_mant, b_mant;
	wire [EXPONENTWIDTH - 1:0] mult_exp, exp_sum;
	wire norm, zero_test;

	assign a_sign = a[WIDTH - 1];
	assign a_exp = a[WIDTH - 2:MANTISSAWIDTH];
	assign a_mant[MANTISSAWIDTH - 1:0] = a[MANTISSAWIDTH - 1:0];	// mantissa of a
	assign a_mant[MANTISSAWIDTH] = 1; // add leading 1

	assign b_sign = b[WIDTH - 1];
	assign b_exp = b[WIDTH - 2:MANTISSAWIDTH];
	assign b_mant[MANTISSAWIDTH - 1:0] = b[MANTISSAWIDTH - 1:0];	// mantissa of b
	assign b_mant[MANTISSAWIDTH] = 1; // add leading 1
	 
	mult24 mult0(.a(a_mant), .b(b_mant), .mult(mult_mant));	// multiply mantissas

	// Calculate New Exponent
	// (a_exp + b_exp - 127) = mult_exp
	adder8 add0(.a(a_exp), .b(b_exp), .cin(1'b0), .sum(exp_sum), .cout());
	adder8 sub0(.a(exp_sum), .b(~(8'd 127)), .cin(1'b1), .sum(mult_exp), .cout());

	// if most significant bit of mantissa is 1, then the float needs to be normalized
	assign norm = mult_mant[MANTISSAOVERFLOW];
	  
	// if norm == 0, don't normalize float
	// if norm == 1, shift mantissa to the left, add 1 to exponent
	assign mult_mantnorm = mult_mant >> 1;
	assign mult[MANTISSAWIDTH - 1:0] = (norm) ?
											mult_mantnorm[MANTISSAOVERFLOW - 2:MANTISSAWIDTH] :
											mult_mant[MANTISSAOVERFLOW - 2:MANTISSAWIDTH];
	adder8 add1(.a(mult_exp), .b({7'd0,norm}), .cin(1'b0), .sum(mult[WIDTH - 2:MANTISSAWIDTH]), .cout());	// normalize exponent

	xor calc_sign(mult[WIDTH - 1], a_sign, b_sign);	// handle sign

	// if either a or b is zero, output = zero
	assign zero_test = ((a==32'd0) || (b==32'd0));
	assign m = (zero_test) ? 32'd0 : // if zero_test is 1, output is zero
				(mult[WIDTH - 2:MANTISSAWIDTH] == 8'hFF) ? {mult[WIDTH - 1:MANTISSAWIDTH], 23'd0} : //test if result is infinite
					mult;

endmodule //mult_float
