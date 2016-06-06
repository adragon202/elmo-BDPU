
/*
cout,sum = a + b + cin
Carry Lookahead adder
Output is buffered, made available on clk.
INPUTS:
	a = bit 0
	b = bit 1
	cin = carry in bit
OUTPUTS:
	sum = bit 0 of output
	cout = carry out bit (bit 1 of output)
*/
module adder64(a, b, cin, sum, cout);
	//input declaration
	input [63:0] a, b;
	input cin;
	//output declaration
	output [63:0] sum;
	output cout;
	//port data types
	wire [63:0] a, b, sum;
	wire cin, cout;
	//internal wires
	wire [3:0] C, G, P;
	//code starts here

	//Carry Look-Ahead
	assign C[0] = G[0] | (P[0] & C[0]);
	assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
	assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);

	//Sum
	adder16 Add0(.a(a[15:0]),	.b(b[15:0]),	.cin(cin),	.sum(sum[15:0]),	.cout(),		.PG(P[0]),	.GG(G[0]));
	adder16 Add1(.a(a[31:16]),	.b(b[31:16]),	.cin(C[0]),	.sum(sum[31:16]),	.cout(),		.PG(P[1]),	.GG(G[1]));
	adder16 Add2(.a(a[47:32]),	.b(b[47:32]),	.cin(C[1]),	.sum(sum[47:32]),	.cout(),		.PG(P[2]),	.GG(G[2]));
	adder16 Add3(.a(a[63:48]),	.b(b[63:48]),	.cin(C[2]),	.sum(sum[63:48]),	.cout(cout),	.PG(P[3]),	.GG(G[3]));

endmodule //adder64

/*
cout,sum = a + b + cin
Carry Lookahead
INPUTS:
	a = 16 bits
	b = 16 bits
	cin = carry in bit
OUTPUTS:
	sum = 16 bits
	cout = carry out bit
*/
module adder16( a, b, cin, sum, cout, PG, GG);
	//input declaration
	input [15:0] a, b;
	input cin;
	//output declaration
	output [15:0] sum;
	output cout, PG, GG;
	//port data types
	wire [15:0] a, b, sum;
	wire cin, cout;
	//internal wires
	wire [3:0] C, G, P;
	//code starts here
	//Carry Look-Ahead
	assign C[0] = G[0] | (P[0] & cin);
	assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
	assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
	assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

	//Sum
	adder4 Add0(.a(a[3:0]),		.b(b[3:0]),		.cin(cin),	.sum(sum[3:0]),		.cout(),		.PG(P[0]),	.GG(G[0]));
	adder4 Add1(.a(a[7:4]),		.b(b[7:4]),		.cin(C[0]),	.sum(sum[7:4]),		.cout(),		.PG(P[1]),	.GG(G[1]));
	adder4 Add2(.a(a[11:8]),	.b(b[11:8]),	.cin(C[1]),	.sum(sum[11:8]),	.cout(),		.PG(P[2]),	.GG(G[2]));
	adder4 Add3(.a(a[15:12]),	.b(b[15:12]),	.cin(C[2]),	.sum(sum[15:12]),	.cout(cout),	.PG(P[3]),	.GG(G[3]));

	//Propogation and Generation
	assign PG = P[3] & P[2] & P[1] & P[0];
	assign GG = C[3];

endmodule //adder16

/*
cout,sum = a + b + cin
Carry Lookahead
INPUTS:
	a = 4 bits
	b = 4 bits
	cin = carry in bit
OUTPUTS:
	sum = 4 bits
	cout = carry out bit
*/
module adder4( a, b, cin, sum, cout, PG, GG);
	//input declaration
	input [3:0] a, b;
	input cin;
	//output declaration
	output [3:0] sum;
	output cout, PG, GG;
	//port data types
	wire [3:0] a, b, sum;
	wire cin, cout;
	//internal wires
	wire [3:0] C, G, P;
	//code starts here
	//Carry Look-Ahead
	assign G = a & b; //Generate
	assign P = a ^ b; //Propagate
	assign C[0] = cin;
	assign C[1] = G[0] | (P[0] & C[0]);
	assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
	assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);

	//Sum
	assign sum = P ^ C;
	assign cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

	//Propogation and Generation
	assign PG = P[3] & P[2] & P[1] & P[0];
	assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);

endmodule //adder4

/*
cout,sum = a + b + cin
INPUTS:
	a = bit 0
	b = bit 1
	cin = carry in bit
OUTPUTS:
	sum = bit 0 of output
	cout = carry out bit (bit 1 of output)
*/
module addbit( a, b, cin, sum, cout);
	//input declaration
	input a, b, cin;
	//output declaration
	output sum, cout;
	//port data types
	wire a, b, cin, sum, cout;
	//internal wires
	wire oA_sum, oA_cout0, oA_cout1, oA_cout2; //and gate outputs
	wire oX_sum; //xor gate outputs
	//code starts here
	// SUM Calculation
	xor X_sum(oX_sum, a, b, cin);
	and A_sum(oA_sum, a, b, cin);
	or  O_sum(sum,oX_sum,oA_sum);

	// COUT Calculation
	and A_cout0(oA_cout0, a, b);
	and A_cout1(oA_cout1, b, cin);
	and A_cout2(oA_cout2, a, cin);
	or  O_cout(cout, oA_cout0, oA_cout1, oA_cout2);

endmodule //addbit
