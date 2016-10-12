
module accumulator(EN, clk, rst, pre, vals, rdy, sum, in0, in1, sum0, sum1, sum2, sum3);
	parameter FLOAT=0; //Define either FLOAT or INT Adders
	parameter WIDTH=16; //quantity of inputs
	parameter LAYERS=4; //How many addition iterations occur = log_2(WIDTH) //TODO: Replace with localparam and $clog2()
	//local parameters
	localparam VARWIDTH=32; //size of inputs
	//States
	localparam STATE_INIT = 0;
	localparam STATE_CALC = 1;
	localparam STATE_COMPLETE = 2;
	//input declaration
	input EN, clk, rst, pre;
	input [VARWIDTH*WIDTH - 1:0] vals;
	wire [VARWIDTH - 1:0] in_vals [0:WIDTH-1];
	generate
		genvar count;
		for (count = WIDTH; count > 0; count = count - 1)
		begin:in_vals_assignment
			assign in_vals[count-1] = vals[count*VARWIDTH-1:(count-1)*VARWIDTH];
		end
	endgenerate
	//output declaration
	output rdy;
	output [VARWIDTH - 1:0] sum;
	reg rdy;
	reg [VARWIDTH - 1:0] sum;
	//diagnostic output
	output [VARWIDTH-1:0] in0;
	wire [VARWIDTH-1:0] in0 = add_in[0];
	output [VARWIDTH-1:0] in1;
	wire [VARWIDTH-1:0] in1 = add_in[1];
	output [VARWIDTH-1:0] sum0;
	wire [VARWIDTH-1:0] sum0 = add_sum[0];
	output [VARWIDTH-1:0] sum1;
	wire [VARWIDTH-1:0] sum1 = add_sum[1];
	output [VARWIDTH-1:0] sum2;
	wire [VARWIDTH-1:0] sum2 = add_sum[2];
	output [VARWIDTH-1:0] sum3;
	wire [VARWIDTH-1:0] sum3 = add_sum[3];
	//internal data types
	reg [1:0] state;
	reg [VARWIDTH-1:0] sum_preserve;
	reg [VARWIDTH-1:0] add_in [0:WIDTH-1];
	wire [VARWIDTH-1:0] sum_total;
	wire [VARWIDTH-1:0] add_sum [0:(WIDTH/2)-1];
	reg [7:0] itercount;
	wire [7:0] itercount_next;
	//beginning of code

	// Generate Adders
	generate
		// Generate Adder Layers
		// genvar count; //see in_vals_assignment
		for (count = 0; count < WIDTH; count = count + 2)
		begin:add_modules
			if (FLOAT) begin
				add_f32 addf32_layer(.a(add_in[count]),
										.b(add_in[count+1]),
										.sum(add_sum[count/2]));
			end else begin
				adder32 add32_layer(.a(add_in[count]),
									.b(add_in[count+1]),
									.cin(1'b0),
									.sum(add_sum[count/2]),
									.cout());
			end
		end
		// Generate Preservation Adder
		if (FLOAT) begin
			add_f32 addf32_preserve(.a(add_sum[0]),
									.b(sum_preserve),
									.sum(sum_total));
		end else begin
			adder32 add32_preserve(.a(add_sum[0]),
									.b(sum_preserve),
									.cin(1'b0),
									.sum(sum_total)
									.cout());
		end
	endgenerate

	// Iteration Counter
	adder8 adder8_iter(.a(itercount), .b(8'd0), .cin(1'b1), .sum(itercount_next));

	integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			rdy <= 0;
			sum <= 0;
			itercount <= 0;
			//Zero adder inputs
			for (i = 0; i < WIDTH; i = i + 1)
			begin
				add_in[i] <= 0;
			end
			state <= STATE_INIT;
			if (pre) begin
				sum_preserve <= sum_total;
			end else begin
				sum_preserve <= 0;
			end
		end
		else if (clk == 1) begin
			if (EN == 1) begin
				case (state)
					STATE_INIT : begin
						rdy <= 0;
						itercount <= 0;
						//Set adder inputs to accumulators inputs
						for (i = 0; i < WIDTH; i = i +1)
						begin
							add_in[i] <= in_vals[i];
						end
						state <= STATE_CALC;
					end
					STATE_CALC : begin
						rdy <= 0;
						itercount <= itercount_next;
						//Set Adder Inputs to Adder outputs
						for (i = 0; i < WIDTH/2; i = i + 1)
						begin
							add_in[i] <= add_sum[i];
						end
						//Zero unused Adder Inputs
						for (i = WIDTH/2; i < WIDTH; i = i + 1)
						begin
							add_in[i] <= 0;
						end
						//If all adders sum to zero except for first then complete
						if (itercount == (LAYERS-1)) begin
							state <= STATE_COMPLETE;
						end else begin
							state <= STATE_CALC;
						end
					end
					STATE_COMPLETE : begin
						rdy <= 1;
						sum <= sum_total;
						state <= STATE_COMPLETE;
					end
					default : begin
						state <= STATE_COMPLETE;
					end
				endcase
			end
		end
	end
endmodule //accumulator