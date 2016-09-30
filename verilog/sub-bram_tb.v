
module ram_tb();
parameter DATA_WIDTH = 32;  // number of bits in the output
parameter ADD_WIDTH = 10;   // number of bits in the address 
parameter RAM_SIZE = 1 << ADD_WIDTH;  // ram size

reg clk, cs, we, oe; 
reg [ADD_WIDTH-1:0] add;
reg [DATA_WIDTH-1:0] data_in; 
wire [DATA_WIDTH-1:0] data_out;

initial begin 
	// write 0x00 to address 0x00
	#0 clk = 0;
	#0 add = 0;
	#0 data_in = 32'd0;
	#0 cs = 1;
	#0 oe = 0;
	#0 we = 1;
	// write 0xFF to address 0x0A
	#20 add = 10'h0A;
	#0 data_in = 32'd1737075661;
	// read from address 0x00
	#50 add = 10'h00;
	#0 we = 0;
	#0 oe = 1;
	// read from address 0x0A
	#50 add = 10'h0A;
	// write to address 0x49
	#20 add = 10'h49;
	#0 oe = 0;
	#0 we = 1;
	#0 data_in = 32'd906748088;
	// write to address 0x285
	#20 add = 10'h288;
	#0 data_in = 32'd612097388;
	// write to address 0x1EF
	#20 add = 10'h1EF;
	#0 data_in = 32'd23;
	// write to address 0x285
	#20 add = 10'h285;
	#0 data_in = 32'd52520419;
	// write to address 0x3E8
	#20 add = 10'h3E8;
	#0 data_in = 32'd184362242;
	// write to address 0x31D
	#20 add = 10'h31D;
	#0 data_in = 32'd239383947;

	// read data at each address
	#50 we = 0;
	#0 oe = 1;
	#20 add = 10'h49;
	#20 add = 10'h288;
	#20 add = 10'h1EF;
	#20 add = 10'h285;
	#20 add = 10'h3E8;
	#20 add = 10'h31D;
	#100 $stop; 
end 

always begin 
	#5 clk = ~clk;
end 

ram R_TEST(clk, add, data_in, data_out, cs, we, oe);
defparam R_TEST.DATA_WIDTH = DATA_WIDTH;
defparam R_TEST.ADD_WIDTH = ADD_WIDTH;
defparam R_TEST.RAM_SIZE = RAM_SIZE;

endmodule // ram_tb
