module vec_loader (clk, rst, en, sqrt_rdy, data_flags, VECTOR_WIDTH, bram_add, dram_add, dist_add, done); 
parameter ADD_WIDTH = 20;
parameter HEADER_LENGTH = 2;
// state definitions
localparam INIT = 0;
localparam LOAD_VECTOR_COUNT = 1;
localparam LOAD_VECTOR_WIDTH = 2;
localparam LOAD_VECTOR_INDEX = 3;
localparam LOAD_TARGET = 4;
localparam LOAD_TRAIN = 5;
localparam WAIT = 6;

// inputs
input clk;
input rst;
input en;
input sqrt_rdy;
input [31:0] VECTOR_WIDTH;
// outputs
output reg done;
output reg [5:0] data_flags;  // determines where the DRAM data is stored
output [ADD_WIDTH-1:0] dram_add, bram_add;
output reg [ADD_WIDTH-1:0] dist_add;
// local signals
reg [ADD_WIDTH-1:0] base_add, index;
reg ld_header, ld_index;
reg index_rst, index_inc;
reg base_rst, base_inc;
reg dist_rst, dist_inc;
reg [3:0] state, next_state;

// calculate address
assign dram_add = (ld_header) ? (index):            // load the header 
				  (ld_index)  ? (base_add - 1):     // load the index
				                (base_add + index); // load the vector
assign bram_add = index;

// increment counter
always @(posedge clk) begin 
	if (index_rst) begin 
		index <= 0;
	end 
	else if (index_inc) begin 
		index <= index + 1;
	end 

	if (base_rst) begin 
		base_add <= HEADER_LENGTH + 1;  // point to element zero of the first vector
	end 
	else if (base_inc) begin 
		base_add <= base_add + VECTOR_WIDTH + 1; 
	end 

	if (dist_rst) begin 
		dist_add <= 0;
	end 
	else if (dist_inc) begin 
		dist_add <= dist_add + 1;
	end 
end  

always@(posedge clk) begin  
	if (rst) 
		state <= INIT;
	else 
		state <= next_state;
end 

always @(*) begin 
	case (state) 
		INIT: begin 
			if(en) begin 
				next_state = LOAD_VECTOR_COUNT;
				index_rst = 1'b1;  // reset counter 
				index_inc = 1'b1;
				base_rst = 1'b1;
			end 
			else begin 
				next_state = INIT; 
				index_rst = 1'b0;
				index_inc = 1'b0;
				base_rst = 1'b0;
			end 
            base_inc = 1'b0;
            data_flags = 6'b000000;
            done = 1'b0;
            ld_header = 1'b0;
            ld_index = 1'b0;
            dist_inc = 1'b0;
            dist_rst = 1'b1;
		end 
		LOAD_VECTOR_COUNT: begin 
			data_flags = 6'b000001;
			next_state = LOAD_VECTOR_WIDTH;
			base_inc = 1'b0;
            done = 1'b0;
            index_rst = 1'b0; 
			index_inc = 1'b1;
			base_rst = 1'b0;
			ld_header = 1'b1;
			ld_index = 1'b0;
			dist_inc = 1'b0;
			dist_rst = 1'b0;
		end 
		LOAD_VECTOR_WIDTH: begin 
			data_flags = 6'b000010;
			next_state = LOAD_VECTOR_INDEX;
			base_inc = 1'b0;
            done = 1'b0;
            index_rst = 1'b1;  // reset counter 
			index_inc = 1'b0;
			base_rst = 1'b0;
			ld_header = 1'b1;
			ld_index = 1'b0;
			dist_inc = 1'b0;
			dist_rst = 1'b0;
		end 
		LOAD_VECTOR_INDEX: begin 
			data_flags = 6'b000100;
			next_state = LOAD_TARGET;
			base_inc = 1'b0;
            done = 1'b0;
            index_rst = 1'b0;   
			index_inc = 1'b0;
			base_rst = 1'b0;
			ld_header = 1'b0;
			ld_index = 1'b1;
			dist_inc = 1'b0;
			dist_rst = 1'b0;
		end 
		LOAD_TARGET: begin 
			// wait until all elements have been loaded
			if (index < VECTOR_WIDTH) begin 
				next_state = LOAD_TARGET;
				index_rst = 1'b0;
				index_inc = 1'b1;
				base_inc = 1'b0;
				data_flags = 6'b001000;
			end else begin 
				next_state = LOAD_TRAIN;
				index_rst = 1'b1;
				index_inc = 1'b1;
				base_inc = 1'b1;
				data_flags = 6'b000000;
			end 
			base_rst = 1'b0;
			done = 1'b0;
			ld_header = 1'b0;
			ld_index = 1'b0;
			dist_inc = 1'b0;
			dist_rst = 1'b0;
		end 
		LOAD_TRAIN: begin 
			// wait until all elements have been loaded
			if (index < VECTOR_WIDTH) begin 
				next_state = LOAD_TRAIN;
				index_rst = 1'b0;
				index_inc = 1'b1;
				data_flags = 6'b010000;
			end else begin 
				next_state = WAIT;
				index_rst = 1'b1;
				index_inc = 1'b1;
				data_flags = 6'b000000;
			end 
			base_inc = 1'b0;
			base_rst = 1'b0;
			done = 1'b0;
			ld_header = 1'b0;
			ld_index = 1'b0;
			dist_inc = 1'b0;
			dist_rst = 1'b0;
		end 
		WAIT: begin 
			if (sqrt_rdy) begin 
				next_state = LOAD_TRAIN;  // load the next train vector
				index_rst = 1'b0;
				index_inc = 1'b0;
				base_inc = 1'b1;
				done = 1'b1;
				data_flags = 6'b100000;
				dist_inc = 1'b1;
			end 
			else begin 
				next_state = WAIT;  // wait until enable signal
				index_rst = 1'b0;
				index_inc = 1'b0;
				base_inc = 1'b0;
				done = 1'b1;
				data_flags = 6'b000000;
            	dist_inc = 1'b0;
			end 
            base_rst = 1'b0;
            ld_header = 1'b0;
            ld_index = 1'b0;
            dist_rst = 1'b0;
		end 
		default: begin 
			next_state = INIT;
			index_rst = 1'b1;
			index_inc = 1'b1;
			data_flags = 6'b000000;
            base_inc = 1'b0;
            base_rst = 1'b0;
            done = 1'b1;
            ld_header = 1'b0;
            ld_index = 1'b0;
            dist_inc = 1'b0;
            dist_rst = 1'b0;
		end 
	endcase
end 

endmodule