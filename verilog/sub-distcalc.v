module distcalc_euclid(clk, EN_Pipe, EN_Acc, EN_Sqrt, RST_Acc, RST_Sqrt, PRE_Acc, invec0, invec1, RDY_Pipe, RDY_Acc, RDY_Sqrt, outval);
	//Parameters
	parameter VARWIDTH=32;
	parameter PIPEWIDTH=16;
	//Inputs
	input clk;
	input EN_Pipe;
	input EN_Acc;
	input EN_Sqrt;
	input RST_Acc;
	input RST_Sqrt;
	input PRE_Acc;
	input [VARWIDTH*PIPEWIDTH-1:0]invec0;
	input [VARWIDTH*PIPEWIDTH-1:0]invec1;
	//Outputs
	output RDY_Pipe;
	output RDY_Acc;
	output RDY_Sqrt;
	output [VARWIDTH-1:0]outval;
	//Internal Data Types
	wire [VARWIDTH*PIPEWIDTH-1:0]in_pipe0;
	wire [VARWIDTH*PIPEWIDTH-1:0]in_pipe1;
	wire [VARWIDTH*PIPEWIDTH-1:0]out_pipe;
	reg [VARWIDTH*PIPEWIDTH-1:0]in_acc;
	wire [VARWIDTH-1:0]out_acc;
	reg [VARWIDTH-1:0]in_sqrt;
	wire [VARWIDTH-1:0]out_sqrt;
	//Code

	//Modules
	pipes_diffsquare #(.WIDTH(PIPEWIDTH)) pipes(
		.EN(EN_Pipe),
		.vals0(in_pipe0), .vals1(in_pipe1),
		.pipeout(out_pipe));
	accumulator #(.FLOAT(1), .WIDTH(PIPEWIDTH)) accum(
		.EN(EN_Acc), .clk(clk), .rst(RST_Acc), .pre(PRE_Acc),
		.vals(in_acc),
		.rdy(RDY_Acc),
		.sum(out_acc));
	squareroot #(.WIDTH(VARWIDTH)) sqrt(
		.EN(EN_Sqrt), .clk(clk), .rst(RST_Sqrt),
		.a(in_sqrt),
		.rdy(RDY_Sqrt),
		.sqrt(out_sqrt));

	//Default Assignments
	assign in_pipe0 = invec0;
	assign in_pipe1 = invec1;

	//State Machine
	always @(*) begin
		if (EN_Pipe) begin
			in_acc <= out_pipe;
			RDY_Pipe <= 0;
		end else begin
			RDY_Pipe <= 1;
			in_acc <= in_acc;
		end

		if (RDY_Acc) begin
			in_sqrt <= out_acc;
		end else begin
			in_sqrt <= in_sqrt;
		end

		if (RDY_Sqrt) begin
			outval <= out_sqrt;
		end else begin
			outval <= 0;
		end
	end

endmodule //end distcalc_euclid
