
module ram_tb();
parameter DATA_WIDTH = 32;  // number of bits in the output
parameter ADD_WIDTH = 4;   // number of bits in the address 
parameter RAM_SIZE = 1 << ADD_WIDTH;  // ram size
parameter PIPE_SIZE = 4;  

reg clk, cs, we, oe; 
reg [ADD_WIDTH-1:0] add;
reg [DATA_WIDTH-1:0] data_in; 
wire [DATA_WIDTH*PIPE_SIZE-1:0] data_out;
wire [DATA_WIDTH-1:0] data0, data1, data2, data3;

ram #(.varWIDTH(32), .ADD_WIDTH(ADD_WIDTH), .PIPE_WIDTH(PIPE_SIZE)) RAM_TEST(clk, add, data_in, data_out, cs, we, oe);

assign data0 = data_out[31:0];
assign data1 = data_out[63:32];
assign data2 = data_out[95:64];
assign data3 = data_out[DATA_WIDTH*PIPE_SIZE-1:96];

initial begin 
	// write to address 0
	#0 clk = 0;
	#0 cs = 1;
	#0 we = 1;
	#0 oe = 0;
	#0 add = 4'd0;
	#0 data_in = 32'd5;
	// write to address 1
	#35 add = 4'd1;
	#0  data_in = 32'd15;
	// write to address 2 
	#35 add = 4'd2;
	#0 data_in = 32'd25;
	// write to address 3 
	#35 add = 4'd3;
	#0 data_in = 32'd23;
	// write to address 4
	#35 add = 4'd4;
	#0 data_in = 32'd12341234;
	// add 5
	#35 add = 4'd5;
	#0 data_in = 32'd12323;
	// add 6 
	#35 add = 4'd6;
	#0 data_in = 32'd0;
	// add 7
	#35 add = 4'd7;
	#0 data_in = 32'd12;
	// add 8
	#35 add = 4'd8;
	#0 data_in = 32'd1303;

	// read first 4 address
	#35 we = 0;
		  oe = 1;
		  add = 4'd0;
	// read next 4
	#35 add = 4'd4;
	// read next 4
	#35 add = 4'd8;

	#35 add = 4'd12;


	// read address 1
	#35 add = 4'd1;
	#100 $stop; 
end 

always begin 
	#5 clk = ~clk;
end 


endmodule // ram_tb
