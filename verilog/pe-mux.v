
/*
if switch == 0, out = a
if switch == 1, out = b
INPUTS:
	a = 23 bits
	b = 23 bits
	switch = toggle inputs to output
OUTPUTS:
	out = 23 bits
*/
module mux23(a, b, switch, out);
	// inputs 
	input [22:0] a,b;
	input switch;
	// outputs
	output [22:0] out;

	// create 8 1-bit muxes
	genvar i;
	generate
		for (i=0; i<23; i=i+1)
		begin : genmux23
			mux1Bit mux(.a(a[i]), .b(b[i]), .switch(switch), .out(out[i]));
		end
	endgenerate

endmodule //mux23

/*
if switch == 0, out = a
if switch == 1, out = b
INPUTS:
	a = 32 bits
	b = 32 bits
	switch = toggle inputs to output
OUTPUTS:
	out = 32 bits
*/
module mux32(a, b, switch, out);
	// inputs 
	input [31:0] a,b;
	input switch;
	// outputs
	output [31:0] out;

	// create 8 1-bit muxes
	genvar i;
	generate
		for (i=0; i<32; i=i+1)
		begin : genmux32
			mux1Bit mux(.a(a[i]), .b(b[i]), .switch(switch), .out(out[i]));
		end
	endgenerate

endmodule //mux32

/*
if switch == 0, out = a
if switch == 1, out = b
INPUTS:
	a = 1 bit
	b = 1 bit
	switch = toggle inputs to output
OUTPUTS:
	out = 1 bit
*/
module mux1Bit(a, b, switch, out);
	//inputs
	input a,b, switch;
	//outputs
	output out;
	//internal wires
	wire enableA, enableB;

	//logic
	and and0(enableA, a, ~switch);
	and and1(enableB, b, switch);
	or or0(out, enableA, enableB);

endmodule //mux1Bit
