module square_f32( a, sqr);
	//input declaration
	input [31:0] a;
	//output declaration
	output [31:0] sqr;
	//code starts here
	mult_f32 M1(.a(a),.b(a),.m(sqr));

endmodule //square_f32