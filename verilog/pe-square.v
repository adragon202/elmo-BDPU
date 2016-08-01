module square( a, sqr);
	//input declaration
	input a;
	//output declaration
	output sqr;
	//code starts here
	mult32 M1(.a(a),.b(a),.prod(sqr));

endmodule //addbit