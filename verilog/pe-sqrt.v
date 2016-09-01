module squareroot_f32(clk, rst, a, rdy, sqrt);
	localparam WIDTH = 32;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] a;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] sqrt;
	//port data types
	wire rdy;
	wire [WIDTH - 1:0] a, sqrt;
	//code starts here

squareroot_f32_approximation sqrtf32(.clk(clk), .rst(rst), .a(a), .rdy(rdy), .sqrt(sqrt));

endmodule //squareroot_f32

/*
short isqrt(short num) {
    short res = 0;
    short bit = 1 << 14; // The second-to-top bit is set: 1 << 30 for 32 bits
 
    // "bit" starts at the highest power of four <= the argument.
    while (bit > num)
        bit >>= 2;
        
    while (bit != 0) {
        if (num >= res + bit) {
            num -= res + bit;
            res = (res >> 1) + bit;
        }
        else
            res >>= 1;
        bit >>= 2;
    }
    return res;
}
INPUTS:
	clk = clock input to drive operations
	rst = reset for new input
	a = Number to find Square Root for
OUTPUTS:
	rdy = flag output is valid
	sqrt = Square Root of input
*/
module squareroot_f32_digit_by_digit(clk, rst, a, rdy, sqrt);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] a;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] sqrt;
	//port data types
	wire clk, rst;
	wire [WIDTH - 1:0] a;
	wire a_sign = a[WIDTH - 1];
	wire [EXPONENTWIDTH - 1:0] a_exp = a[WIDTH - 2:MANTISSAWIDTH];
	wire [MANTISSAWIDTH:0] a_mant = {1'b1,a[MANTISSAWIDTH - 1:0]};
	wire [WIDTH - 1:0] sqrt;
	wire sqrt_sign;
	wire [EXPONENTWIDTH - 1:0] sqrt_exp;
	reg [MANTISSAWIDTH - 1:0] sqrt_mant;
	//Internal data types
	wire [EXPONENTWIDTH-1:0] exp_denorm;
	reg rdy;
	reg [WIDTH - 1:0] guess;
	wire [WIDTH - 1:0] bit_init;
	reg [WIDTH - 1:0] bit;
	//code starts here

	//============Resolve sign=================
	assign sqrt_sign = a_sign; //No need to acknowledge imaginary numbers in this module.

	//============Resolve exponent=================
	//((exponent - 127) >> 1) + 127
	//if exponent < 127 then result[7] == 0
	adder8 add8_exp1(.a(a_exp), .b(8'd 129), .sum(exp_denorm)); // a_exp - 127
	adder8 add8_exp2(.a({1'b0,exp_denorm[EXPONENTWIDTH-1:1]}), .b(8'd 127), .sum(sqrt_exp)); //(exp_denorm >> 1) + 127

	//============Resolve Mantissa=================
	//Initial Bit Value
	// highestpower32(.a({()a_mant}), b, rem)

	// always @(posedge clk or posedge rst) begin
	// 	if (rst) begin
	// 		// reset
	// 		rdy <= 0;
	// 		sqrt_mant <= 0;
	// 	end
	// 	else if (!rst && clk) begin
			
	// 	end
	// end

	assign sqrt = {sqrt_sign,
		{(a_exp < 127) ? 1'b0 : sqrt_exp[EXPONENTWIDTH - 1], sqrt_exp[EXPONENTWIDTH - 2:0]}, //exponent < 127 then null highest bit
		sqrt_mant};
endmodule //squareroot_f32_digit_by_digit

/*
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

