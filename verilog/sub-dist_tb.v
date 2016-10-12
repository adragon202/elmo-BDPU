module test;
	localparam varWIDTH=32;
	localparam vecWIDTH=10;
	localparam pipeWIDTH=16;

	initial begin
		// TODO: Load vectors into Bram
		// TODO: initiate control unit and generate output
		# 1000 $stop;
	end

	/* Pulse input */
	reg clk, START;
	wire en_p, en_a, en_s;
	wire rdy_p, rdy_a, rdy_s;
	wire rst_p, rst_a, rst_s;
	wire [$clog2(vecWIDTH)-1:0] addr_b;
	wire [3:0] flag_b;
	reg [varWIDTH-1:0] loadedvector0[vecWIDTH-1:0];
	reg [varWIDTH*vecWIDTH-1:0] vector0;
	wire [varWIDTH-1:0] loadedvector1[vecWIDTH-1:0];
	wire [varWIDTH*vecWIDTH-1:0] vector1;
	reg [varWIDTH-1:0] distance;

	generate
		genvar i;
		for (i = 0; i < n; i = i + 1)
		begin:identifier
			assign vector0[i*varWIDTH-1:(i-1)*vecWIDTH] = loadedvector0[i-1];
			assign vector1[i*varWIDTH-1:(i-1)*vecWIDTH] = loadedvector1[i-1];
		end
	endgenerate

	ram #(.DATA_WIDTH(varWIDTH), .ADD_WIDTH(#clog2(vecWIDTH))) bram(
		.clk(clk),
		.add(addr_b),
		.data_in(),
		.data_out((flag_b[0]) ? loadedvector0[0] : loadedvector1[0]), //TODO: Have CU generate i value in place of 0
		.cs(flag_b[3]), .we(flag_b[2]), .oe(flag_b[1]));

	distcalc_euclid #(.VARWIDTH(varWIDTH), .PIPEWIDTH(pipeWIDTH)) distcalc(
		.clk(clk),
		.EN_Pipe(en_p), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (inputs)
		.RST_Acc(rst_a), .RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets (inputs)
		.invec0(vector0), .invec1(vector1),
		.RDY_Pipe(rdy_p), .RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s), //Ready Flags (outputs)
		.outval());

	dist_control_unit distctrl(.NUM_OF_VECTORS(), .VECTOR_WIDTH(),
		.clk(clk), .STARTCALC(START),
		.EN_Pipe(en_p), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (outputs)
		.RST_Acc(rst_a), RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets
		.RDY_Pipe(rdy_p), .RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s),
		.ADDR_Bram(addr_b), .FLAG_Bram(flag_b)); //Ready Flags (inputs)
	initial
		$monitor("%g\t\n",
				$time);

endmodule //test