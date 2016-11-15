
module BRAM(clk, add, data_in, data_out, cs, we, oe);
// parameters
parameter varWIDTH = 32;    // number of bits in a word
parameter ADD_WIDTH = 10;   // number of bits in the address
parameter PIPE_WIDTH = 16;  // number of words in the output

// inputs 
input clk,cs,we;
input [PIPE_WIDTH-1:0] oe;
input [varWIDTH-1:0] data_in;
input [ADD_WIDTH-1:0] add;

// outputs 
output [varWIDTH*PIPE_WIDTH-1:0] data_out;

// internal signals
wire [ADD_WIDTH-$clog2(PIPE_WIDTH)-1:0] add_eff;
wire [$clog2(PIPE_WIDTH)-1:0] rem;
wire [PIPE_WIDTH-1:0] write_en, we_decode;

// handle the address and write enable 
assign add_eff = add >> $clog2(PIPE_WIDTH);
assign rem = add[$clog2(PIPE_WIDTH)-1:0];  // rem is used to select one of the blocks for writing 
assign we_decode = 1 << rem;               // this is a decoder, it selects the one block we are writing to
assign write_en = (we) ? we_decode:{PIPE_WIDTH{1'b0}};  // when writing, only one block should be selected

// create multiple BRAM modules(equal to the number of pipes)
generate
	genvar i;
	for (i = PIPE_WIDTH; i > 0; i = i - 1)
	begin:identifier
		ram #(.varWIDTH(varWIDTH), .ADD_WIDTH(ADD_WIDTH-$clog2(PIPE_WIDTH))) bram_vector(
		.clk(clk),
		.add(add_eff),
		.data_in(data_in),
		.data_out(data_out[i*varWIDTH-1 -: varWIDTH]), 
		.cs(cs), .we(write_en[i-1]), .oe(oe[i-1]));
	end
endgenerate

endmodule

module ram(clk, add, data_in, data_out, cs, we, oe);
	parameter varWIDTH = 32;  // number of bits in the output
	parameter ADD_WIDTH = 10;   // number of bits in the address
	parameter FILENAME = "";
	localparam [63:0] RAM_SIZE = 1 << ADD_WIDTH;  // ram size

	//input declaration
	input clk;
	input cs;  // chip select
	input we;  // enables writing
	input oe;  // output enable
	input [ADD_WIDTH-1:0] add; // address
	input [varWIDTH-1:0] data_in;

	//output declaration
	output reg [varWIDTH-1:0] data_out;

	// internal variables
	reg [varWIDTH-1:0] memory [0:RAM_SIZE-1];

	//code starts here
	// initalize memory from file
	initial begin
		if (FILENAME != "") 
  		$readmemh(FILENAME, memory);
  end

	// handle writing to RAM
	always @(posedge clk) begin
		if (cs && we)
			memory[add] <= data_in;
	end

	// handle reading from RAM
	always @(posedge clk) begin
		if (cs && !we && oe) 
			data_out <= memory[add];
		else 
			data_out <= {varWIDTH{1'b0}};
	end

endmodule //ram