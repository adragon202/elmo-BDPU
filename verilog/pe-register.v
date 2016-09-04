
module reg32(
	input clk,		            // data is stored on rising edge 
	input en,			            // data is stored only when enable is high
	input reset, 	            // synchronous reset
	input [WIDTH-1:0] data,   // data you want to store
	output reg [WIDTH-1:0] q  // current data stored in register
	);
	localparam WIDTH = 32;

	always @(posedge clk) begin 
		if (reset) begin 
			q <= 0;
		end 
		else if (en) begin 
			q <= data;
		end 
	end 

endmodule
