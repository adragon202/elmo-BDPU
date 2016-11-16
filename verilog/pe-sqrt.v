module squareroot_f32(clk, rst, EN, a, rdy, sqrt);
	localparam WIDTH = 32;
	//input declaration
	input clk, rst, EN;
	input [WIDTH - 1:0] a;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] sqrt;
	//port data types
	wire rdy;
	wire [WIDTH - 1:0] a, sqrt;
	//code starts here

	sqrt32_bit_by_bit sqrtf32(.clk(clk), .rst(rst), .EN(EN), .a(a), .rdy(rdy), .sqrt(sqrt));

endmodule //squareroot_f32

/*
*********************************NOT OPERATIONAL*********************************
Uses approximation method
#1. Set den to 2
#2. a/den = result (float)
#3. if den == result then DONE
#4. mean(den,result,mn) (float)
#5. set den = mn
#6. Repeat from step 2
INPUTS:
	clk = clock input to drive operations
	rst = reset for new input
	a = Number to find Square Root for
OUTPUTS:
	rdy = flag output is valid
	sqrt = Square Root of input
*/
module squareroot_f32_approximation(clk, rst, a, rdy, sqrt, state, den, divide_result, result, mn);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	localparam STATE_INIT = 0;
	localparam STATE_BEGINDIVIDE = 1;
	localparam STATE_DIVIDE = 2;
	localparam STATE_EVALDIVIDE = 3;
	localparam STATE_BEGINMEAN = 4;
	localparam STATE_MEAN = 5;
	localparam STATE_EVALMEAN = 6;
	localparam STATE_COMPLETE = 7;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] a;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] sqrt;
	output [WIDTH - 1:0] divide_result;
	output [WIDTH - 1:0] den;
	output [WIDTH - 1:0] mn;
	output [WIDTH - 1:0] result;
	output [2:0] state;
	//port data types
	wire [WIDTH - 1:0] a;
	wire a_sign = a[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] a_exp = a[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH:0] a_mant = {1'b1,a[MANTISSAWIDTH - 1:0]};
	reg rdy;
	wire [WIDTH - 1:0] sqrt;
	wire [EXPONENTWIDTH - 1:0] sqrt_exp;
	//internal data types
	wire [EXPONENTWIDTH-1:0] exp_denorm;
	reg divide_rst;
	wire divide_rdy;
	reg mean_rst;
	wire mean_rdy;
	wire [WIDTH - 1:0] mn, divide_result;
	reg [WIDTH - 1:0] den, result;
	reg [2:0] state = 0;
	//code starts here

	//============Resolve exponent=================
	//((exponent - 127) >> 1) + 127
	//if exponent < 127 then result[7] == 0
	adder8 add8_exp1(.a(a_exp), .b(8'd 129), .cin(1'b0), .sum(exp_denorm)); // a_exp - 127
	adder8 add8_exp2(.a({1'b0,exp_denorm[EXPONENTWIDTH-1:1]}), .cin(1'b0), .b(8'd 127), .sum(sqrt_exp)); //(exp_denorm >> 1) + 127

	//Evaluate for solution
	divide_f32 divide_f32_1(.clk(clk), .rst(divide_rst), .num(a), .den(den), .rdy(divide_rdy), .quo(divide_result));
	mean2_f32 M1(.clk(clk), .rst(mean_rst), .a(den), .b(result), .rdy(mean_rdy), .mean(mn));
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			divide_rst <= 1;
			mean_rst <= 0;
			den <= 32'h40000000; //initial denominator at 2.
			rdy <= 0;
			result <= 0;
			// sqrt <= 0;
			state <= STATE_INIT;
		end
		else if (!rst && clk) begin
			if (!rdy) begin
				if (state == STATE_INIT) begin //Initialize
					mean_rst <= 1;
					divide_rst <= 1;
					den <= {1'b0,(a_exp < 127) ? 1'b0 :
						sqrt_exp[EXPONENTWIDTH - 1], sqrt_exp[EXPONENTWIDTH - 2:0],23'd0}; //exponent < 127 then null highest bit
					state <= STATE_BEGINDIVIDE;
				end else if (state == STATE_BEGINDIVIDE) begin //Begin Division
					mean_rst <= 1;
					divide_rst <= 1;
					state <= STATE_DIVIDE;
				end	else if (state == STATE_DIVIDE) begin //Await Division to complete
					mean_rst <= 1;
					divide_rst <= 0;
					state <= (divide_rdy) ? STATE_EVALDIVIDE: STATE_DIVIDE;
				end else if (state == STATE_EVALDIVIDE) begin //Division is complete
					mean_rst <= 1;
					divide_rst <= 0;
					if (den == divide_result) begin
						// sqrt <= divide_result;
						state <= STATE_COMPLETE;
					end else begin
						state <= STATE_BEGINMEAN;
					end
				end else if (state == STATE_BEGINMEAN) begin //Begin Mean Calculation
					mean_rst <= 1;
					divide_rst <= 0;
					result <= divide_result;
					den <= mn;
					state <= STATE_MEAN;
				end else if (state == STATE_MEAN) begin //Await Mean to complete
					mean_rst <= 0;
					divide_rst <= 0;
					state <= (mean_rdy) ? STATE_EVALMEAN : STATE_MEAN;
				end else if (state == STATE_EVALMEAN) begin //Mean calculation is complete
					mean_rst <= 0;
					divide_rst <= 0;
					den <= mn;
					state <= STATE_BEGINDIVIDE;
				end else if (state == STATE_COMPLETE) begin //Process is complete
					mean_rst <= 0;
					divide_rst <= 0;
					rdy <= 1;
				end else begin
					state <= STATE_COMPLETE;
				end
			end
		end
	end
	assign sqrt = {a_sign,divide_result[WIDTH-2:0]};
endmodule //squareroot_f32_approximation

/////////////////////////////////////////////////////////////////////////
// calculates square root by finding each bit of the mantissa one by one
// procedure: 
// 		0. find exponent, set mantissa = 0
//	  1. set mantissa[22] = 1
//		2. square result 
//		3. if result is greater than a, mantissa[22] should be 0
//		4. repeat from step 1 for all bits in the mantissa
/////////////////////////////////////////////////////////////////////////
module sqrt32_bit_by_bit(
	input clk, 							 // clock signal	
	input rst, 							 // reset signal
	input EN,
	input [WIDTH-1:0] a,     // input floating number 
	output reg rdy, 				 // flag signals data is ready
	output [WIDTH-1:0] sqrt  // square root of input a
	); 
	// definitions
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	localparam EXPONENTBIAS = 127;
	localparam IDLE = 0;
	localparam STATE_TEST = 1;
	localparam STATE_COMPLETE = 2;
	// reg types
	reg [MANTISSAWIDTH-1:0] sqrt_mant, next_sqrt_mant;
	reg [MANTISSAWIDTH-1:0] set_bit_high, next_high;
	reg [1:0] state, next_state;

	// local wires
	wire [WIDTH-1:0] sqrt_guess;
	wire [WIDTH-1:0] square_sqrt_guess; 
	wire [MANTISSAWIDTH-1:0] a_mant = a[MANTISSAWIDTH-1:0];
	wire [MANTISSAWIDTH-1:0] mant_guess, square_sqrt_guess_mant;
	wire [EXPONENTWIDTH-1:0] exp_denorm;
	wire [EXPONENTWIDTH-1:0] a_exp = a[WIDTH-2:MANTISSAWIDTH];
	wire [EXPONENTWIDTH-1:0] sqrt_exp;
	wire greater_test;

	// calculate exponent
	adder8 add8_exp1(.a(a_exp), .b(8'd 129), .sum(exp_denorm), .cin(1'b0)); // a_exp - EXPONENTBIAS
	adder8 add8_exp2(.a($signed(exp_denorm) >>> 1), .b(8'd 127), .sum(sqrt_exp), .cin(1'b0)); //(exp_denorm >> 1) + EXPONENTBIAS

	// square current_sqrt
	mult_f32 square_current_sqrt(.a(sqrt_guess), .b(sqrt_guess), .m(square_sqrt_guess));

	// set current bit of mantissa to 1
	assign mant_guess = sqrt_mant | set_bit_high;
	assign sqrt_guess = {1'b0, sqrt_exp, mant_guess};
	assign greater_test = square_sqrt_guess[WIDTH-2:0] > a[WIDTH-2:0];
	assign square_sqrt_guess_mant = square_sqrt_guess[MANTISSAWIDTH-1:0];

	initial begin 
		state <= IDLE;
	end 

	// transition to the next state
	always @(posedge clk) begin 
		if (rst == 1) begin 
			state <= STATE_TEST;
			sqrt_mant <= 23'd0;
			set_bit_high <= 23'h400000;  // most significant bit is set to 1
		end 
		else if (EN) begin 
			if ((a_exp == 0 || a_exp == 8'hff) && a_mant == 0) begin // Check for 0 or infinite
				state <= STATE_COMPLETE;
				sqrt_mant <= 23'd0;
				set_bit_high <= 0;
		end else if (a_exp == 8'hff && a_mant != 0) begin // Check for NaN
				state <= STATE_COMPLETE;
				sqrt_mant <= 23'h7fffff;
				set_bit_high <= 0;
		end else begin
				state <= next_state;
				sqrt_mant	<= next_sqrt_mant;
				set_bit_high <= next_high;  
		end
		end 
	end 

	// calculate next state and output
	always @(*) begin
		next_high = set_bit_high >> 1;  // shift right to set next bit high
		case (state) 
			IDLE: begin
				rdy = 0;
				next_state = IDLE;
				next_sqrt_mant = sqrt_mant;
			end 
			STATE_TEST: begin 
				rdy = 0;
				// test if sqrt_guess is correct
				if (square_sqrt_guess[WIDTH-2:0] == a[WIDTH-2:0]) begin 
					next_state = STATE_COMPLETE;  // answer found 
					next_sqrt_mant = mant_guess;
				end 
				// test if sqrt_guess is too big
				else if (greater_test) begin 
					next_state = STATE_TEST;     // continue testing
					next_sqrt_mant = sqrt_mant;  // don't change mantissa 
				end 
				else if (set_bit_high == 23'd0) begin 
					next_state = STATE_COMPLETE;
					next_sqrt_mant = sqrt_mant;
				end 
				else begin 
					next_state = STATE_TEST;  // current bit is correct, but continue testing
					next_sqrt_mant = mant_guess;  
				end 
			end 
			STATE_COMPLETE: begin 
				rdy = 1;
				next_state = STATE_COMPLETE;
				next_sqrt_mant = sqrt_mant;
			end 
			default: begin  // shouldn't ever get here
				rdy = 0;
				next_state = STATE_TEST;
				next_sqrt_mant = sqrt_mant;
			end 
		endcase
	end 

	assign sqrt = {a[WIDTH - 1], 
					(a_exp == 8'hff) ? 8'hff : //Check for NaN or infinite
					(a_exp == 0 && a_mant == 0) ? 8'd0 : //Check for 0
					(a_exp < EXPONENTBIAS) ? {1'b0, sqrt_exp[EXPONENTWIDTH - 2:0]} : //exponent < EXPONENTBIAS then null highest bit
						sqrt_exp,
					sqrt_mant};

endmodule
