module test;
	localparam varWIDTH=32;
	localparam vecWIDTH=10;
	localparam pipeWIDTH=16;

	initial begin

		# 1000 $stop;
	end

	/* Pulse input */
	reg clk, START;
	wire en_p, en_a, en_s;
	wire rdy_p, rdy_a, rdy_s;
	wire rst_p, rst_a, rst_s;
	reg [varWIDTH-1:0] distance;

	ram #(.DATA_WIDTH(varWIDTH), .ADD_WIDTH(#clog2(vecWIDTH))) bram(
		.clk(clk),
		.add(),
		.data_in(),
		.data_out(),
		.cs(), .we(), .oe());

	distcalc_euclid #(.VARWIDTH(varWIDTH), .PIPEWIDTH(pipeWIDTH)) distcalc(
		.clk(clk),
		.EN_Pipe(en_p), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (inputs)
		.RST_Acc(rst_a), .RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets (inputs)
		.invec0(), .invec1(),
		.RDY_Pipe(rdy_p), .RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s), //Ready Flags (outputs)
		.outval());

	dist_control_unit distctrl(.NUM_OF_VECTORS(), .VECTOR_WIDTH(),
		.clk(clk), .STARTCALC(START),
		.EN_Pipe(en_p), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (outputs)
		.RST_Acc(rst_a), RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets
		.RDY_Pipe(rdy_p), .RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s)); //Rady Flags (inputs)
	initial
		$monitor("%g\t\n",
				$time);

endmodule //test