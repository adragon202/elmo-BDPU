module squareroot(EN, clk, rst, a, rdy, sqrt);
	parameter WIDTH = 32;
	//input declaration
	input EN, clk, rst;
	input [WIDTH - 1:0] a;
	//output declaration
	output rdy;
	wire rdy;
	output [WIDTH - 1:0] sqrt;
	reg [WIDTH - 1:0] sqrt;
	//internal data types
	reg rst_internal;
	wire [WIDTH - 1:0] sqrt_internal;
	//code starts here

	squareroot_f32 sqrtf32(.clk(clk), .rst(rst_internal), .a(a), .rdy(rdy), .sqrt(sqrt_internal));
	always @(*) begin
		if (EN) begin
			rst_internal <= 0;
			if (rdy && EN) begin
				sqrt <= sqrt_internal;
			end else begin
				sqrt <= 0;
			end
		end else begin
			sqrt <= 0;
			rst_internal <= rst;
		end
	end

endmodule //squareroot_f32