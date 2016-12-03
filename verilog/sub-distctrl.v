
/*process:
*	process first vector
*		calculate address
*		get first set of data from RAM
*		send data to pipes
*		wait until the accumulator is done
*		reset accumulator, increment index count
*		repeat until each index of the vector has been processed
*	output accumulator value to RAM
*	repeat until all vectors have been processed
*
*STATE INIT: do nothing
*STATE 0:
*	reset accumulator (no preserve)
*	calculate data address
*STATE 1:
*	wait until the accumulator is ready
*STATE 2:
*	increment index counter
*	reset accumulator (with preserve)
*	if end of vector
*		go to STATE 3
*	else
*		calculate data address
*		go to STATE 1
*STATE 3:
*	send accumulator to square root
*	wait for square root
*/
module dist_control_unit(VECTOR_WIDTH, clk, STARTCALC, RDY_Acc, RDY_Sqrt, EN_Pipe, EN_Acc, RST_Acc, RST_P, PRE_Acc, EN_Sqrt, RST_Sqrt, ADDR_RAM);
	parameter pipeWIDTH = 16;
	parameter ADD_WIDTH = 10;   // number of bits in the address
	// STATE definitions
	localparam STATE_IDLE = 0;
	localparam STATE_HARD_RESET = 1;
	localparam STATE_WAIT_ACC = 2;
	localparam STATE_SOFT_RESET = 3;
	localparam STATE_WAIT_SQRT = 4;
	// Inputs
	input [7:0] VECTOR_WIDTH;  // number of elements in each vector
	input clk;
	input STARTCALC;
	input RDY_Acc;
	input RDY_Sqrt;
	// Outputs
	output reg RST_Acc;  // resets the accumulator
	output reg PRE_Acc;  // preserve flag for the accumulator
	output reg EN_Acc;   // when high, accumlator does its thing
	output reg EN_Sqrt;  // flag enables the sqrt
	output reg [pipeWIDTH-1:0] EN_Pipe;
	output reg RST_Sqrt, RST_P;
	output [ADD_WIDTH-1:0] ADDR_RAM;   // keep track of current index(since base address is always zero, this is the current address)
	// internal signals
	reg [2:0] state, next_state;
	reg index_inc, index_rst;	   // control signals for the index counter
	integer diff;
	reg [ADD_WIDTH-1:0] index_count; 


	always @(negedge clk) begin
		state <= next_state;
	end

	// handle index/addresses
	always @(posedge clk) begin 
		if (index_rst)  
				index_count <= {ADD_WIDTH{1'b0}}; 
		else if(index_inc) 
			index_count <= index_count + pipeWIDTH;
	end 

	assign ADDR_RAM = index_count;

	// handle output enable: determines which BRAM blocks are enabled
	always @(*) begin 
		// if index_count + pipeWidth is greater than VECTOR_WIDTH, zero the rest of the pipes
		diff = (index_count + pipeWIDTH) - VECTOR_WIDTH;
		if (diff > 0 )
			EN_Pipe = {pipeWIDTH{1'b1}} >> diff;  // if end of vector, zero out the remaining pipes
		else 
			EN_Pipe = {pipeWIDTH{1'b1}};          // enable all pipes
	end 

	always @(*) begin
		case (state) 
		// wait until STARTCALC signal
		// reset counters
		STATE_IDLE: begin
			EN_Acc = 1'b0;
			RST_Acc = 1'b0;
			RST_P = 1'b0;
			PRE_Acc = 1'b0;
			EN_Sqrt = 1'b0;
			index_inc = 1'b0;
			index_rst = 1'b0;
			RST_Sqrt = 1'b1;
			if (STARTCALC == 1) 
				next_state = STATE_HARD_RESET;
			else 
				next_state = STATE_IDLE;
		end
		// reset accumulator don't preserve sum
		STATE_HARD_RESET: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b1;
			RST_P = 1'b1;
			PRE_Acc = 1'b0;  // don't preserve running sum
			EN_Sqrt = 1'b0;
			index_inc = 1'b0;
			index_rst = 1'b1;  // reset index counter
			RST_Sqrt = 1'b1;
			next_state = STATE_WAIT_ACC;
		end
		// wait for the accumulator to signal ready
		STATE_WAIT_ACC: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b0;
			RST_P = 1'b0;
			PRE_Acc = 1'b0;
			index_inc = 1'b0;
			index_rst = 1'b0;
			EN_Sqrt = 1'b0;
			if (RDY_Acc == 1) begin
				if (diff >= 0)  begin // have we reached the end of the vector?
					next_state = STATE_WAIT_SQRT;  // move on to the square root phase
					RST_Sqrt = 1'b1;  // reset the squre root module
				end 
				else begin 
					next_state = STATE_SOFT_RESET; // continue accumulating until end of vector
					RST_Sqrt = 1'b0;
				end 
			end
			else begin
				next_state = STATE_WAIT_ACC;   // keep waiting until accumulator is done
				RST_Sqrt = 1'b0;
			end
		end
		// reset the accumulator, but with preserve
		STATE_SOFT_RESET: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b1;
			RST_P = 1'b1;
			PRE_Acc = 1'b1;  // preserve previous sum
			EN_Sqrt = 1'b0;
			index_inc = 1'b1; // increment index to get next address
			index_rst = 1'b0;
			RST_Sqrt = 1'b0;
			next_state = STATE_WAIT_ACC;  // continue with next set of data
		end
		// enable sqrt, then wait for ready signal
		STATE_WAIT_SQRT: begin
			EN_Acc = 1'b0;
			RST_Acc = 1'b0;
			RST_P = 1'b0;
			PRE_Acc	= 1'b0;
			EN_Sqrt = 1'b1;  // start the square root module
			index_inc = 1'b0;
			index_rst = 1'b0;
			RST_Sqrt = 1'b0;
			// is sqrt done?
			if (STARTCALC == 1'b1) begin
				next_state = STATE_WAIT_SQRT;  // do nothing until sqrt is done
			end
			else begin
				next_state = STATE_IDLE;  // start over with the next vectors
			end
		end
		default: begin  // THIS STATE SHOULD NEVER BE REACHED
			EN_Acc = 1'b0;
			next_state = STATE_IDLE;
			RST_Acc = 1'b0;
			RST_P = 1'b0;
			PRE_Acc = 1'b0;
			EN_Sqrt = 1'b0;
			index_inc = 1'b0;
			index_rst = 1'b0;
			RST_Sqrt = 1'b0;
		end
		endcase
	end

endmodule // dist_control_unit