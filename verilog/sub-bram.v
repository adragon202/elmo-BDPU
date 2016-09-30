
module ram( clk, add, data_in, data_out, cs, we, oe);
	parameter DATA_WIDTH = 32;  // number of bits in the output
	parameter ADD_WIDTH = 10;   // number of bits in the address 
	parameter RAM_SIZE = 1 << ADD_WIDTH;  // ram size

	//input declaration
	input clk;
	input cs;  // chip select
	input we;  // enables writing
	input oe;  // output enable
	input [ADD_WIDTH-1:0] add; // address
	input [DATA_WIDTH-1:0] data_in;  // bidirectional port

	//output declaration
	output reg [DATA_WIDTH-1:0] data_out;

	// internal variables  
	reg [DATA_WIDTH-1:0] memory [0:RAM_SIZE-1];

	//code starts here

	// handle writing to RAM
	always @(posedge clk) begin 
		if (cs && we) 
			memory[add] = data_in;
	end 

	// handle reading from RAM 
	always @(posedge clk) begin 
		if (cs && !we && oe)
			data_out = memory[add]; 
	end 

endmodule //ram