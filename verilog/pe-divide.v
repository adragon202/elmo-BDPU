
/*
*quo = num / den
*performed by recriprocal approximation (Newton-Raphson Method)
*INPUTS:
*	clk = clock input (trigger low to high)
*	rst = reset input (trigger low to high)
*	num = numerator float
*	den = denominator float
*OUTPUTS:
*	rdy = output is ready
*	quo = quotient as float
*/
module divide_f32(clk, rst, num, den, rdy, quo);
	localparam WIDTH = 32;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] num, den;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] quo;
	//port data types
	wire [WIDTH - 1:0] denrecip;
	//code starts here

	recip_f32 rec_1(.clk(clk), .rst(rst), .val(den), .rdy(rdy), .recip(denrecip));
	// mult_float mult_1(.a(num), .b(denrecip), .mult(quo));
	
endmodule //divide_f

/*
*recip = 1/val
*INPUTS:
*	clk = clock input (trigger low to high)
*	rst = reset input (trigger low to high)
*	val = value float
*OUTPUTS:
*	rdy = output is ready
*	recip = reciprocal of value
*/
module recip_f32(clk, rst, val, rdy, recip);
	localparam WIDTH = 32;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] val;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] recip;
	//port data types
	reg rdy;
	reg [WIDTH - 1:0] recip;
	//Flags and internal calculations
	reg init;
	wire [WIDTH - 1:0] init_4817 = 32'd01000000001101001011010010110101;
	wire [WIDTH - 1:0] init_n3217 = 32'd10111111111100001111000011110001;
	wire [WIDTH - 1:0] init_mult;
	wire [WIDTH - 1:0] iter_2 = 32'd01000000000000000000000000000000;
	wire [WIDTH - 1:0] iter_mult;
	wire [WIDTH - 1:0] recip_next;
	wire [WIDTH - 1:0] recip_test;
	//code starts here
	//Sign Bit remains the same
	recip[WIDTH - 1] = val[WIDTH - 1];

	//Test that reciprocal is valid
	mult_f32 multf32_test1(.a(val), .b(recip), .m(recip_test));
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			init = 1;
			rdy = 0;
			recip[WIDTH - 2:0] = 0;
		end
		else if (!rst & clk) begin
			//Don't try to calculate if the answer is already acceptable
			if (rdy == 0) begin
				//Set initial Guess
				if (init == 1) begin
					if (val == 0) begin
						recip = 0;
						rdy = 1;
					end else begin
						//recip = 48/17 - 32/17 * val_D(Normalized with Exponent equal to )
						mult_f32 multf32_initialguess(.a({9'b001111110,val[22:0]}), .b(init_3217), .m(init_mult));
						add_f32 addf32_initialguess(.a(init_4817), .b(init_mult), .sum(recip)); //TODO: Make Floating Point Adder
					end
					init = 0;
				//Perform Adjustment
				end else begin
					//recip_next = recip_current(2 - value*recip_current)
					mult_f32 multf32_itermult(.a({1'b1,val[30:0]}), .b(recip), .m(iter_mult));
					add_f32 addf32_iteradd(.a(iter_2), .b(iter_mult), .m(iter_add)); //TOOD: Make Floating Point Adder
					mult_f32 multf32_iternext(.a(recip), .b(iter_add), .m(recip_next));
				end
				//Evalute if the solution is acceptable
				if (recip_test == 1) begin
					rdy = 1;
				end
			end
		end
	end

endmodule //recip_f