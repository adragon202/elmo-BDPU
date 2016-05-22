module addbit( a, b, cin, sum, cout);
	//input declaration
	input a, b, cin;
	//output declaration
	output sum, cout;
	//port data types
	wire a, b, cin, sum, cout;
	//code starts here
	assign {cout,sum} = a + b + cin;

endmodule //addbit