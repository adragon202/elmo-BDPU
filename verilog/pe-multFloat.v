
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

assign mantA[22:0] = a[22:0];  // mantissa of a
assign mantA[23] = 1;   			 // add leading 1

assign mantB[22:0] = b[22:0];  // mantissa of b
assign mantB[23] = 1;   			 // add leading 1
 
mult24 mult0(.a(mantA), .b(mantB), .mult(mantissa));  // multiply mantissas

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
adder8 add1(.a(ex), .b({7'd0,norm}), .cin(1'b0), .sum(mult[30:23]), .cout()); // normalize exponent

xor calc_sign(mult[31], a[31], b[31]);  // handle sign

// if either a or b is zero, output = zero
assign zero_test = ((a==32'd0) || (b==32'd0));
mux32 m1(.a(mult), .b(32'd0), .switch(zero_test), .out(m));  // if zero_test is 1, output is zero

endmodule


module mult24(a, b, mult);
//inputs
input [23:0] a;
input [23:0] b;
//outputs
output [47:0] mult;

wire [24:0] w[0:46];

assign w[0][23:0] = (a[0] == 1) ? b : 0;
assign w[0][24] = 0;

genvar i;
generate 
    //for loop used to create 63 adders
    for (i = 0; i<23; i=i+1) begin
        //if current bit of a == 1, then add b to previous sum
        assign w[2*i+1][23:0] = (a[i+1] == 1) ? b : 0;
        assign mult[i] = w[2*i][0];
        //create adder
        adder24 adder(.a(w[2*i][24:1]),      
                        .b(w[2*i+1][23:0]), 
                        .cin(1'b0), 
                        .sum(w[2*i+2][23:0]), 
                        .cout(w[2*i+2][24]));
    end
endgenerate

assign mult[47:23] = w[46];

endmodule

module adder24(a, b, cin, sum, cout);
	//input declaration
	input [23:0] a, b;
	input cin;
	//output declaration
	output [23:0] sum;
	output cout;
	//internal wires
	wire [1:0] C;
	//code starts here

	// create 3 8-bit adders
	adder8 add0(.a(a[7:0]), .b(b[7:0]), .cin(cin), .sum(sum[7:0]), .cout(C[0]));
	adder8 add1(.a(a[15:8]), .b(b[15:8]), .cin(C[0]), .sum(sum[15:8]), .cout(C[1]));
	adder8 add2(.a(a[23:16]), .b(b[23:16]), .cin(C[1]), .sum(sum[23:16]), .cout(cout));

endmodule

module adder8(a, b, cin, sum, cout);
	//input declaration
	input [7:0] a, b;
	input cin;
	//output declaration
	output [7:0] sum;
	output cout;
	//port data types
	wire [7:0] a, b, sum;
	wire cin, cout;
	//internal wires
	wire [1:0] C, G, P;
	//code starts here
	//Carry Look-Ahead
	assign C[0] = G[0] | (P[0] & cin);
	assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);

	//Sum
	adder4 Add0(.a(a[3:0]),		.b(b[3:0]),		.cin(cin),	.sum(sum[3:0]),		.cout(),		.PG(P[0]),	.GG(G[0]));
	adder4 Add1(.a(a[7:4]),		.b(b[7:4]),		.cin(C[0]),	.sum(sum[7:4]),		.cout(cout),		.PG(P[1]),	.GG(G[1]));

endmodule 


// behavior:
	// if switch == 0, out = a
	// if switch == 1, out = b
module mux23(a, b, switch, out);
// inputs 
input [22:0] a,b;
input switch;
// outputs
output [22:0] out;

// create 8 1-bit muxes
genvar i;
generate
	for (i=0; i<23; i=i+1) begin
		mux1Bit mux(.a(a[i]), .b(b[i]), .switch(switch), .out(out[i]));
	end
endgenerate

endmodule


module mux32(a, b, switch, out);
// inputs 
input [31:0] a,b;
input switch;
// outputs
output [31:0] out;

// create 8 1-bit muxes
genvar i;
generate
	for (i=0; i<32; i=i+1) begin
		mux1Bit mux(.a(a[i]), .b(b[i]), .switch(switch), .out(out[i]));
	end
endgenerate

endmodule


module mux1Bit(a, b, switch, out);
input a,b, switch;
output out;
wire enableA, enableB;

and and0(enableA, a, ~switch);
and and1(enableB, b, switch);
or or0(out, enableA, enableB);

endmodule