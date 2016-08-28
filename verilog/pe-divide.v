
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
	mult_f32 mult_1(.a(num), .b(denrecip), .m(quo));
	
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
*	recip_acc = recip*acc - 1
*/
module recip_f32(clk, rst, val, rdy, recip, recip_acc);
	localparam WIDTH = 32;
	localparam EXPONENTWIDTH = 8;
	localparam MANTISSAWIDTH = 23;
	//input declaration
	input clk, rst;
	input [WIDTH - 1:0] val;
	//output declaration
	output rdy;
	output [WIDTH - 1:0] recip;
	output [WIDTH - 1:0] recip_acc;
	//port data types
	reg rdy;
	reg [WIDTH - 1:0] recip;
	//Flags and internal calculations
	reg init;
	wire [WIDTH - 1:0] init_4817 = 32'h4034b4b5; //48/17
	wire [WIDTH - 1:0] init_n3217 = 32'hbff0f0f1; //-32/17
	wire [WIDTH - 1:0] init_mult;
	wire [WIDTH - 1:0] iter_2 = 32'h40000000; //2
	wire [WIDTH - 1:0] iter_mult;
	wire [WIDTH - 1:0] iter_add;
	wire [WIDTH - 1:0] recip_init;
	wire [WIDTH - 1:0] recip_next;
	wire [WIDTH - 1:0] recip_test;
	wire recip_acc_sign;
	wire [EXPONENTWIDTH - 1:0] recip_acc_exp;
	wire [MANTISSAWIDTH - 1:0] recip_acc_mant;
	wire [WIDTH - 1:0] recip_acc = {recip_acc_sign, recip_acc_exp, recip_acc_mant};
	wire [WIDTH - 1:0] test_one = 32'h3f800000;
	//code starts here

	//Test that reciprocal is valid
	//val * recip - 1 = accuracy
	mult_f32 multf32_test(.a({1'b0,val[WIDTH - 2:0]}), .b({1'b0,recip[WIDTH - 2:0]}), .m(recip_test));
	add_f32 addf32_test(.a(recip_test), .b({1'b1,test_one[WIDTH - 2:0]}),
		.sum({recip_acc_sign,recip_acc_exp,recip_acc_mant}));
	
	//Initial Guess Modules
	//Point for Optimization is to improve initial guess
	//recip = 48/17 - 32/17 * val_D(Normalized with Exponent equal to )
	mult_f32 multf32_initialguess(.a({9'd126, val[22:0]}), .b(init_n3217), .m(init_mult));
	add_f32 addf32_initialguess(.a(init_4817), .b(init_mult), .sum(recip_init));

	//Adjustment/Iteration Modules
	//recip_next = recip_current(2 - value*recip_current)
	mult_f32 multf32_itermult(.a(val), .b(recip), .m(iter_mult));
	add_f32 addf32_iteradd(.a(iter_2), .b({1'b1,iter_mult[WIDTH-2:0]}), .sum(iter_add));
	mult_f32 multf32_iternext(.a(recip), .b(iter_add), .m(recip_next));
	always @(posedge clk or posedge rst) begin
		//Sign Bit remains the same
		if (rst) begin
			// reset
			init <= 1;
			rdy <= 0;
			recip[WIDTH - 2:0] <= 0;
		end
		else if (!rst & clk) begin
			//Don't try to calculate if the answer is already acceptable
			if (rdy == 0) begin
				//Set initial Guess
				if (init == 1) begin
					if (val == 0) begin
						recip<= 0;
						rdy <= 1;
					end else begin
						//Initial Guess
						recip <= recip_init;
					end
					init <= 0;
				//Perform Adjustment
				//Evalute if the solution is acceptable
				end else if (recip_acc_exp == 0) begin //exponent is less than 20 to catch possible infinite loops
					rdy <= 1;
					recip[WIDTH - 1] <= val[WIDTH - 1];
				end else begin
					//Adjustment/Iteration
					recip <= recip_next;
				end
			end
		end
	end

endmodule //recip_f