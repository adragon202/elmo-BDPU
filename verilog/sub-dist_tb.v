module distance_test;
	localparam varWIDTH=32;
	localparam pipeWIDTH=16;
	localparam HEADER_LENGTH = 2;
	parameter ADD_WIDTH = 12 ; // what should the maximum value be?

	/* Pulse input */
	reg clk, START;
	wire en_a, en_s;
	wire rdy_p, rdy_a, rdy_s;
	wire rst_a, rst_s, pre_a;
	wire [ADD_WIDTH-1:0] bram_add, ctrl_add, loader_add, dist_add;
	wire [31:0] dram_add, dram_in, dram_out;
	wire [varWIDTH*pipeWIDTH-1:0] vector0;
	wire [varWIDTH*pipeWIDTH-1:0] vector1;
	wire [varWIDTH-1:0] distance;
	wire [pipeWIDTH-1:0] EN_Pipe;
	wire loader_done;
	wire [5:0] data_flags;
	wire [31:0] vecWIDTH, vecCOUNT, vecINDEX; 
	reg load_vectors, mem_rst;
	
	initial begin
			// Load vectors into Bram
			#0 clk = 1'b0;
			#0 mem_rst = 1'b1;
			
			#35 mem_rst = 1'b0;

			#10 START = 1'b1;
			#35 START = 1'b0;
			
			// TODO: initiate control unit and generate output
		end
		
	always begin 
		#5 clk = !clk; 
	end 

	assign bram_add = (loader_done) ? ctrl_add:loader_add;

	reg32 vector_count(.clk(clk), .en(data_flags[0]), .reset(1'b0), .data(dram_out), .q(vecCOUNT));
	reg32 vector_width(.clk(clk), .en(data_flags[1]), .reset(1'b0), .data(dram_out), .q(vecWIDTH));
	reg32 vector_index(.clk(clk), .en(data_flags[2]), .reset(1'b0), .data(dram_out), .q(vecINDEX));

	// MEMORY CONTROLLER 
   vec_loader #(.ADD_WIDTH(ADD_WIDTH), .HEADER_LENGTH(HEADER_LENGTH)) vec_ctrl(
	.clk(clk), 
	.rst(mem_rst), 
	.en(START), 
	.sqrt_rdy(rdy_s),
	.data_flags(data_flags),
	.VECTOR_WIDTH(vecWIDTH),
	.dram_add(dram_add),
	.bram_add(loader_add), 
	.dist_add(dist_add),
	.done(loader_done)); 
	
	// create "DRAM" 
	ram #(.varWIDTH(varWIDTH), .ADD_WIDTH(ADD_WIDTH), .FILENAME("C:\\Users\\mcowl_000\\Desktop\\GitStuff\\Elmo\\datasets\\simple.list")) dram(
		.clk(!clk),
		.add(dram_add),
		.data_in(dram_in),
		.data_out(dram_out), 
		.cs(1'b1), .we(1'b0), .oe(1'b1));

	// BRAM for the target vector
	BRAM #(.varWIDTH(varWIDTH), .ADD_WIDTH(ADD_WIDTH), .PIPE_WIDTH(pipeWIDTH)) bram_target(
		.clk(clk),
		.add(bram_add),
		.data_in(dram_out),
		.data_out(vector0), 
		.cs(1'b1), .we(data_flags[3]), .oe(EN_Pipe));

	// BRAM for the training vector
	BRAM #(.varWIDTH(varWIDTH), .ADD_WIDTH(ADD_WIDTH), .PIPE_WIDTH(pipeWIDTH)) bram_training(
		.clk(clk),
		.add(bram_add),
		.data_in(dram_out),
		.data_out(vector1), 
		.cs(1'b1), .we(data_flags[4]), .oe(EN_Pipe));

	ram #(.varWIDTH(varWIDTH), .ADD_WIDTH(ADD_WIDTH)) dist_ram(
		.clk(clk),
		.add(dist_add),
		.data_in(distance),
		.data_out(), 
		.cs(1'b1), .we(data_flags[5]), .oe(1'b0));

	distcalc_euclid #(.VARWIDTH(varWIDTH), .PIPEWIDTH(pipeWIDTH)) distcalc(
		.clk(!clk),
		.EN_Pipe(1'b1), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (inputs)
		.RST_Acc(rst_a), .RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets (inputs)
		.invec0(vector0), .invec1(vector1),
		.RDY_Pipe(rdy_p), .RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s), //Ready Flags (outputs)
		.outval(distance));

	dist_control_unit #(.pipeWIDTH(pipeWIDTH), .ADD_WIDTH(ADD_WIDTH)) distctrl(
		.VECTOR_WIDTH(vecWIDTH),
		.clk(clk), .STARTCALC(loader_done),
		.EN_Pipe(EN_Pipe), .EN_Acc(en_a), .EN_Sqrt(en_s), //Enables (outputs)
		.RST_Acc(rst_a), .RST_Sqrt(rst_s), .PRE_Acc(pre_a), //Resets
		.RDY_Acc(rdy_a), .RDY_Sqrt(rdy_s),
		.ADDR_RAM(ctrl_add));

	initial
		$monitor("%g\t\n",
				$time);

endmodule //end distance_test