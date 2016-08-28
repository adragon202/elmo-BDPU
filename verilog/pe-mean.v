module mean2_f32( clk, rst, a, b, rdy, mean);
	localparam WIDTH = 32;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] a;
	input [WIDTH - 1:0] b;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] mean;
	//port data types
	wire rdy;
	wire [WIDTH - 1:0] mean;
	wire [WIDTH - 1:0] num_sum;
	wire [WIDTH - 1:0] den_2 = 32'h40000000; //float value 2
	//code starts here

	add_f32 addf32_num(.a(a), .b(b), .cin(1'b0), .sum(num_sum));
	divide_f32 dividef32_mean(.clk(clk), .rst(rst), .num(num_sum), .den(den_2), .rdy(rdy), .quo(mean));

endmodule //mean2_f32
