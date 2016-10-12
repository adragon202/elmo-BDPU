
// process:
	// process first vector
		// calculate address
		// get first set of data from RAM
		// send data to pipes
		// wait until the accumulator is done
		// reset accumulator, increment index count
		// repeat until each index of the vector has been processed
	// output accumulator value to RAM
	// repeat until all vectors have been processed

module dist_control_unit(NUM_OF_VECTORS, VECTOR_WIDTH, clk, STARTCALC, RDY_Pipe, RDY_Acc, RDY_Sqrt, EN_Pipe, EN_Acc, RST_Acc, PRE_Acc, EN_Sqrt, RST_Sqrt, ADDR_Bram, FLAG_Bram);
	
	// STATE definitions
	localparam STATE_IDLE = 0;
	localparam STATE_HARD_RESET = 1;
	localparam STATE_WAIT_ACC = 2;
	localparam STATE_SOFT_RESET = 3;
	localparam STATE_WAIT_SQRT = 4;
	// Inputs
	input [7:0] NUM_OF_VECTORS;
	input [7:0] VECTOR_WIDTH;
	input clk;
	input STARTCALC;
	input RDY_Acc;
	input RDY_Sqrt;
	// Outputs
	output reg RST_Acc;  // resets the accumulator
	output reg PRE_Acc;  // preserve flag for the accumulator
	output reg EN_Acc;   // when high, accumlator does its thing
	output reg EN_Sqrt;  // flag enables the sqrt
	output [2:0] ADDR_Bram; //TODO, Address of next vector value to load
	output [3:0] FLAG_Bram; //cs, we, oe, (vec0 or vec1)
	// internal signals
	reg [2:0] state, next_state;
	reg vector_count;  // increment counter each time a vector has been processed
	reg index_count;   // increment each time accumulator is reset
	reg inc_vector;	   // when flag is high, vector counter increments


	always @(posedge clk) begin
		state <= next_state;
	end

	// handle counters
	always @(negedge clk) begin
		if (inc_vector == 1'b1)
			vector_count <= vector_count + 1;
	end

	always @(*) begin
		case (state) 
		// wait until STARTCALC signal
		// reset counters
		STATE_IDLE: begin
			EN_Acc = 1'b0;
			RST_Acc = 1'b0;
			PRE_Acc = 1'bx;
			EN_Sqrt = 1'b0;
			inc_vector = 1'b0;
			if (STARTCALC == 1) begin
				next_state = STATE_HARD_RESET;
			end
			else begin
				next_state = STATE_IDLE;
			end
		end
		// reset accumulator don't preserve sum
		STATE_HARD_RESET: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b1;
			PRE_Acc = 1'b0;  // set preserve sum to zero
			EN_Sqrt = 1'b0;
			inc_vector = 1'b0;
			next_state = STATE_WAIT_ACC;
		end
		// wait for the accumulator to signal ready
		STATE_WAIT_ACC: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b0;
			PRE_Acc = 1'bx;
			EN_Sqrt = 1'b0;
			inc_vector = 1'b0;
			if (RDY_Acc == 1) begin
				// have we reached the end of the vector?
				if (index_count >= VECTOR_WIDTH)
					next_state = STATE_WAIT_SQRT;  // move on to the square root phase
				else
					next_state = STATE_SOFT_RESET; // continue accumulating until end of vector
			end
			else begin
				next_state = STATE_WAIT_ACC;   // keep waiting until accumulator is done
			end
		end
		// reset the accumulator, but with preserve
		STATE_SOFT_RESET: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b1;
			PRE_Acc = 1'b1;  // preserve previous sum
			EN_Sqrt = 1'b0;
			inc_vector = 1'b0;
			next_state = STATE_WAIT_ACC;  // continue with next set of data
		end
		// enable sqrt, then wait for ready signal
		STATE_WAIT_SQRT: begin
			EN_Acc = 1'b1;
			RST_Acc = 1'b0;
			PRE_Acc	= 1'bx;
			EN_Sqrt = 1'b1;  // start the square root module
			// is sqrt done?
			if (RDY_Sqrt == 1'b0) begin
				next_state = STATE_WAIT_SQRT;  // do nothing until sqrt is done
				inc_vector = 1'b0;
			end
			else begin
				// have all vectors been handled?
				if (vector_count == NUM_OF_VECTORS) begin
					next_state = STATE_IDLE;
					inc_vector = 1'b0;
				end
				else begin
					next_state = STATE_HARD_RESET;  // continue with the next vector
					inc_vector = 1'b1;
				end
			end
		end
		default: begin  // THIS STATE SHOULD NEVER BE REACHED
			EN_Acc = 1'b1;
			next_state = STATE_IDLE;
			RST_Acc = 1'b0;
			PRE_Acc = 1'bx;
			EN_Sqrt = 1'b0;
			inc_vector = 1'b0;
		end
		endcase
	end

endmodule // dist_control_unit

// STATE INIT: do nothing
// STATE 0:
	// reset accumulator (no preserve)
	// calculate data address
// STATE 1:
	// wait until the accumulator is ready
// STATE 2:
	// increment index counter
	// reset accumulator (with preserve)
	// if end of vector
		// go to STATE 3
	// else
		// calculate data address
		// go to STATE 1
// STATE 3:
	// send accumulator to square root
	// wait for square root