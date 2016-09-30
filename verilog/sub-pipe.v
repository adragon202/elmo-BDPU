

module pipes_diffsquare(EN, vals0, vals1, pipeout);
	parameter WIDTH = 16; //size of each vals vector
	//local parameters
	localparam VARWIDTH = 32;
	//input declaration
	input EN;
	input [VARWIDTH*WIDTH-1:0] vals0, vals1;
	wire [VARWIDTH-1:0] in_vals0 [0:WIDTH-1];
	wire [VARWIDTH-1:0] in_vals1 [0:WIDTH-1];
	generate
		genvar count;
		for (count = WIDTH; count > 0; count = count - 1)
		begin:in_vals_assignment
			assign in_vals0[count-1] = vals0[count*VARWIDTH-1:(count-1)*VARWIDTH];
			assign in_vals1[count-1] = vals1[count*VARWIDTH-1:(count-1)*VARWIDTH];
		end
	endgenerate
	//output declaration
	output [VARWIDTH*WIDTH-1:0] pipeout;
	wire [VARWIDTH*WIDTH-1:0] pipeout; 
	reg [VARWIDTH-1:0] out_pipe [0:WIDTH-1]; 
	generate
		for (count = WIDTH; count > 0; count = count - 1)
		begin:pipeout_assignment
			assign pipeout[count*VARWIDTH-1:(count-1)*VARWIDTH] = out_pipe[count-1];
		end
	endgenerate
	//internal data types
	wire [VARWIDTH-1:0] diffsquare [0:WIDTH-1];
	//code begins here

	generate
		for (count = 0; count < WIDTH; count = count + 1)
		begin:diffsquared_generator
			diffsquared32 diffsquare32_Pipe(.a(in_vals0[count]),
											.b(in_vals1[count]),
											.out(diffsquare[count]));
		end
	endgenerate

	integer i;
	always @(posedge EN or negedge EN) begin
		if (EN) begin //EN high enable output
			for (i = 0; i < WIDTH; i = i + 1)
			begin
				out_pipe[i] <= diffsquare[i];
			end
		end else begin //EN low disable output
			for (i = 0; i < WIDTH; i = i + 1)
			begin
				out_pipe[i] <= 0;
			end
		end
	end

endmodule //end pipes_diffsquare


module diffsquared32(a, b, out);
	localparam VARWIDTH = 32;
	//input declarations
	input [VARWIDTH-1:0] a, b;
	//output declarations
	output [VARWIDTH-1:0] out;
	wire [VARWIDTH-1:0] out;
	//internal wires declaration
	wire [VARWIDTH-1:0] sum;
	wire [VARWIDTH-1:0] float;
	wire [VARWIDTH-1:0] square;
	//code begins here

	adder32 add32_inputs(.a(a), .b(~b), .cin(1'b1), .sum(sum));
	int2float32 i2f32_sum(.a(sum), .b(float));
	square_f32 squaref32_float(.a(float), .sqr(square));
	assign out = square;

endmodule //end diffsquared32