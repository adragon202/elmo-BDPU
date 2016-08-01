
/*
* float definition
*	Sign = 1 bit
*	Exponent = 11 bits
*	Mantissa = 52 bits
*/
module int2float64(a, b);
	input [63:0] a;
	output [63:0] b;

	wire [63:0] infix;
	wire [10:0] highpower;
	wire [63:0] highpowerrem;
	wire [10:0] exp;
	wire [51:0] mant;

	//Undo 2's Compliment if signed
	adder64 input_fix(.a((a[63] == 1) ? ~a : a), .b((a[63] == 1) ? {64'd 1} : 64'd 0), .cin(0), .sum(infix), .cout());
	//Determine Exponent

	//Add Highest Power of 2 to 127, result is exponent
	highestpower64 exp_power(.a(infix), .b(highpower), .rem(highpowerrem));
	adder16 exp_add(.a((a == 0) ? 11'd1025 : highpower), .b(11'd 1023), .cin(0), .sum(exp), .cout(), .PG(), .GG());

	//Determine Mantissa (Fraction)
	//Remainder following Highest Power of 2 is fraction (highpowerrem)
	//Shift amount determined by the exponent
	assign mant = (highpower == 0) ? {52'd0} : 
					(highpower == 1) ? {highpowerrem[0], 51'd0} :
					(highpower == 2) ? {highpowerrem[1:0], 50'd0} :
					(highpower == 3) ? {highpowerrem[2:0], 49'd0} :
					(highpower == 4) ? {highpowerrem[3:0], 48'd0} :
					(highpower == 5) ? {highpowerrem[4:0], 47'd0} :
					(highpower == 6) ? {highpowerrem[5:0], 46'd0} :
					(highpower == 7) ? {highpowerrem[6:0], 45'd0} :
					(highpower == 8) ? {highpowerrem[7:0], 44'd0} :
					(highpower == 9) ? {highpowerrem[8:0], 43'd0} :
					(highpower == 10) ? {highpowerrem[9:0], 42'd0} :
					(highpower == 11) ? {highpowerrem[10:0], 41'd0} :
					(highpower == 12) ? {highpowerrem[11:0], 40'd0} :
					(highpower == 13) ? {highpowerrem[12:0], 39'd0} :
					(highpower == 14) ? {highpowerrem[13:0], 38'd0} :
					(highpower == 15) ? {highpowerrem[14:0], 37'd0} :
					(highpower == 16) ? {highpowerrem[15:0], 36'd0} :
					(highpower == 17) ? {highpowerrem[16:0], 35'd0} :
					(highpower == 18) ? {highpowerrem[17:0], 34'd0} :
					(highpower == 19) ? {highpowerrem[18:0], 33'd0} :
					(highpower == 20) ? {highpowerrem[19:0], 32'd0} :
					(highpower == 21) ? {highpowerrem[20:0], 31'd0} :
					(highpower == 22) ? {highpowerrem[21:0], 30'd0} :
					(highpower == 23) ? {highpowerrem[22:0], 29'd0} :
					(highpower == 24) ? {highpowerrem[23:0], 28'd0} :
					(highpower == 25) ? {highpowerrem[24:0], 27'd0} :
					(highpower == 26) ? {highpowerrem[25:0], 26'd0} :
					(highpower == 27) ? {highpowerrem[26:0], 25'd0} :
					(highpower == 28) ? {highpowerrem[27:0], 24'd0} :
					(highpower == 29) ? {highpowerrem[28:0], 23'd0} :
					(highpower == 30) ? {highpowerrem[29:0], 22'd0} :
					(highpower == 31) ? {highpowerrem[30:0], 21'd0} :
					(highpower == 32) ? {highpowerrem[31:0], 20'd0} :
					(highpower == 33) ? {highpowerrem[32:0], 19'd0} :
					(highpower == 34) ? {highpowerrem[33:0], 18'd0} :
					(highpower == 35) ? {highpowerrem[34:0], 17'd0} :
					(highpower == 36) ? {highpowerrem[35:0], 16'd0} :
					(highpower == 37) ? {highpowerrem[36:0], 15'd0} :
					(highpower == 38) ? {highpowerrem[37:0], 14'd0} :
					(highpower == 39) ? {highpowerrem[38:0], 13'd0} :
					(highpower == 40) ? {highpowerrem[39:0], 12'd0} :
					(highpower == 41) ? {highpowerrem[40:0], 11'd0} :
					(highpower == 42) ? {highpowerrem[41:0], 10'd0} :
					(highpower == 43) ? {highpowerrem[42:0], 9'd0} :
					(highpower == 44) ? {highpowerrem[43:0], 8'd0} :
					(highpower == 45) ? {highpowerrem[44:0], 7'd0} :
					(highpower == 46) ? {highpowerrem[45:0], 6'd0} :
					(highpower == 47) ? {highpowerrem[46:0], 5'd0} :
					(highpower == 48) ? {highpowerrem[47:0], 4'd0} :
					(highpower == 49) ? {highpowerrem[48:0], 3'd0} :
					(highpower == 50) ? {highpowerrem[49:0], 2'd0} :
					(highpower == 51) ? {highpowerrem[50:0], 1'd0} :
					(highpower == 52) ? {highpowerrem[51:0]} :
					(highpower == 53) ? {1'd0, highpowerrem[52:1]} :
					(highpower == 54) ? {2'd0, highpowerrem[53:2]} :
					(highpower == 55) ? {3'd0, highpowerrem[54:3]} :
					(highpower == 56) ? {4'd0, highpowerrem[55:4]} :
					(highpower == 57) ? {5'd0, highpowerrem[56:5]} :
					(highpower == 58) ? {6'd0, highpowerrem[57:6]} :
					(highpower == 59) ? {8'd0, highpowerrem[58:7]} :
					(highpower == 60) ? {9'd0, highpowerrem[59:8]} :
					(highpower == 61) ? {10'd0, highpowerrem[60:9]} :
					(highpower == 62) ? {11'd0, highpowerrem[61:10]} :
					{12'd0, highpowerrem[62:11]};

	//Assign output to contain sign bit, exponent and mantissa
	assign b = {a[63], exp, mant};
endmodule //int2float64

module float2int64(a, b);
	input [63:0] a;
	output [63:0] b;

	reg [62:0] conv;

	assign b = {a[63], conv};

endmodule //float2int64

module highestpower64(a, b, rem);
	input [63:0] a;
	output [10:0] b;
	output [63:0] rem;


	wire [62:1] bcalc;
	
	generate
		genvar i, j, k;
		//essentially bcalc[27] = !a[30] & !a[29] & !a[28] & a[27];
		for (i = 61; i > 0; i = i - 1)
		begin:bcalc_loop
			// assign bcalc[i] = a[i] (~&a[30:i+1]); //TODO: Apply this efficiently like in 32
			assign bcalc[i] = a[i] & !bcalc[i+1];
		end

		//essentially rem[27] = a[27] & (bcalc[30] | bcalc[29] | bcalc[28]);
		for (j = 61; j > -1; j = j - 1)
		begin:remcalc_loop
			assign rem[j] = a[j] & (|bcalc[62:j+1]);//remcalc[j];
		end
	endgenerate

	assign bcalc[62] = a[62];
	
	assign rem[63] = a[63];
	assign rem[62] = 0;

	//Encoder
	//TODO: 28 translates as 31
	assign b[10:6] = 0;
	assign b[5] = |bcalc[62:32];
	assign b[4] = (|bcalc[62:48]) | (|bcalc[31:16]);
	assign b[3] = (|bcalc[62:56]) | (|bcalc[47:40]) | (|bcalc[31:24]) | (|bcalc[15:8]);
	assign b[2] = (|bcalc[62:60]) | (|bcalc[55:52]) | (|bcalc[47:44]) | (|bcalc[39:36]) | (|bcalc[31:28]) | (|bcalc[23:20]) | (|bcalc[15:12]) | (|bcalc[7:4]);
	// assign b[5] = bcalc[62] | bcalc[61] | bcalc[60] | bcalc[59] | bcalc[58] | bcalc[57] | bcalc[56] | bcalc[55] | bcalc[54] | bcalc[53] | bcalc[52] | bcalc[51] | bcalc[50] | bcalc[49] | bcalc[48] | bcalc[47] | bcalc[46] | bcalc[45] | bcalc[44] | bcalc[43] | bcalc[42] | bcalc[41] | bcalc[40] | bcalc[39] | bcalc[38] | bcalc[37] | bcalc[36] | bcalc[35] | bcalc[34] | bcalc[33] | bcalc[32];
	// assign b[4] = bcalc[62] | bcalc[61] | bcalc[60] | bcalc[59] | bcalc[58] | bcalc[57] | bcalc[56] | bcalc[55] | bcalc[54] | bcalc[53] | bcalc[52] | bcalc[51] | bcalc[50] | bcalc[49] | bcalc[48] | bcalc[31] | bcalc[30] | bcalc[29] | bcalc[28] | bcalc[27] | bcalc[26] | bcalc[25] | bcalc[24] | bcalc[23] | bcalc[22] | bcalc[21] | bcalc[20] | bcalc[19] | bcalc[18] | bcalc[17] | bcalc[16];
	// assign b[3] = bcalc[62] | bcalc[61] | bcalc[60] | bcalc[59] | bcalc[58] | bcalc[57] | bcalc[56] | bcalc[47] | bcalc[46] | bcalc[45] | bcalc[44] | bcalc[43] | bcalc[42] | bcalc[41] | bcalc[40] | bcalc[31] | bcalc[30] | bcalc[29] | bcalc[28] | bcalc[27] | bcalc[26] | bcalc[25] | bcalc[24] | bcalc[15] | bcalc[14] | bcalc[13] | bcalc[12] | bcalc[11] | bcalc[10] | bcalc[9] | bcalc[8];
	// assign b[2] = bcalc[62] | bcalc[61] | bcalc[60] | bcalc[55] | bcalc[54] | bcalc[53] | bcalc[52] | bcalc[47] | bcalc[46] | bcalc[45] | bcalc[44] | bcalc[39] | bcalc[38] | bcalc[37] | bcalc[36] | bcalc[31] | bcalc[30] | bcalc[29] | bcalc[28] | bcalc[23] | bcalc[22] | bcalc[21] | bcalc[20] | bcalc[15] | bcalc[14] | bcalc[13] | bcalc[12] | bcalc[7] | bcalc[6] | bcalc[5] | bcalc[4];
	assign b[1] = bcalc[62] | bcalc[59] | bcalc[58] | bcalc[55] | bcalc[54] | bcalc[51] | bcalc[50] | bcalc[47] | bcalc[46] | bcalc[43] | bcalc[42] | bcalc[39] | bcalc[38] | bcalc[35] | bcalc[34] | bcalc[31] | bcalc[30] | bcalc[27] | bcalc[26] | bcalc[23] | bcalc[22] | bcalc[19] | bcalc[18] | bcalc[15] | bcalc[14] | bcalc[11] | bcalc[10] | bcalc[7] | bcalc[6] | bcalc[3] | bcalc[2];
	assign b[0] = bcalc[61] | bcalc[59] | bcalc[57] | bcalc[55] | bcalc[53] | bcalc[51] | bcalc[49] | bcalc[47] | bcalc[45] | bcalc[43] | bcalc[41] | bcalc[39] | bcalc[37] | bcalc[35] | bcalc[33] | bcalc[31] | bcalc[29] | bcalc[27] | bcalc[25] | bcalc[23] | bcalc[21] | bcalc[19] | bcalc[17] | bcalc[15] | bcalc[13] | bcalc[11] | bcalc[9] | bcalc[7] | bcalc[5] | bcalc[3] | bcalc[1];

endmodule //highestpower64

/*
* float definition
*	Sign = 1 bit
*	Exponent = 8 bits
*	Mantissa = 23 bits
*/
module int2float32(a, b);
	input [31:0] a;
	output [31:0] b;

	wire [31:0] infix;
	wire [7:0] highpower;
	wire [31:0] highpowerrem;
	wire [7:0] exp;
	wire [22:0] mant;

	//Undo 2's Compliment if signed
	adder32 input_fix(.a((a[31] == 1) ? ~a : a), .b((a[31] == 1) ? {32'd 1} : 32'd 0), .cin(0), .sum(infix), .cout());
	//Determine Exponent

	//Add Highest Power of 2 to 127, result is exponent
	highestpower32 exp_power(.a(infix), .b(highpower), .rem(highpowerrem));
	adder8 exp_add(.a((a == 0) ? 8'd129 : highpower), .b(8'd 127), .cin(0), .sum(exp), .cout(), .PG(), .GG());

	//Determine Mantissa (Fraction)
	//Remainder following Highest Power of 2 is fraction (highpowerrem)
	//Shift amount determined by the exponent
	assign mant = (highpower == 0) ? {23'd0} : 
					(highpower == 1) ? {highpowerrem[0], 22'd0} :
					(highpower == 2) ? {highpowerrem[1:0], 21'd0} :
					(highpower == 3) ? {highpowerrem[2:0], 20'd0} :
					(highpower == 4) ? {highpowerrem[3:0], 19'd0} :
					(highpower == 5) ? {highpowerrem[4:0], 18'd0} :
					(highpower == 6) ? {highpowerrem[5:0], 17'd0} :
					(highpower == 7) ? {highpowerrem[6:0], 16'd0} :
					(highpower == 8) ? {highpowerrem[7:0], 15'd0} :
					(highpower == 9) ? {highpowerrem[8:0], 14'd0} :
					(highpower == 10) ? {highpowerrem[9:0], 13'd0} :
					(highpower == 11) ? {highpowerrem[10:0], 12'd0} :
					(highpower == 12) ? {highpowerrem[11:0], 11'd0} :
					(highpower == 13) ? {highpowerrem[12:0], 10'd0} :
					(highpower == 14) ? {highpowerrem[13:0], 9'd0} :
					(highpower == 15) ? {highpowerrem[14:0], 8'd0} :
					(highpower == 16) ? {highpowerrem[15:0], 7'd0} :
					(highpower == 17) ? {highpowerrem[16:0], 6'd0} :
					(highpower == 18) ? {highpowerrem[17:0], 5'd0} :
					(highpower == 19) ? {highpowerrem[18:0], 4'd0} :
					(highpower == 20) ? {highpowerrem[19:0], 3'd0} :
					(highpower == 21) ? {highpowerrem[20:0], 2'd0} :
					(highpower == 22) ? {highpowerrem[21:0], 1'd0} :
					(highpower == 23) ? {highpowerrem[22:0]} :
					(highpower == 24) ? {1'd0, highpowerrem[23:1]} :
					(highpower == 25) ? {2'd0, highpowerrem[24:2]} :
					(highpower == 26) ? {3'd0, highpowerrem[25:3]} :
					(highpower == 27) ? {4'd0, highpowerrem[26:4]} :
					(highpower == 28) ? {5'd0, highpowerrem[27:5]} :
					(highpower == 29) ? {6'd0, highpowerrem[28:6]} :
					{7'd0, highpowerrem[29:7]};

	//Assign output to contain sign bit, exponent and mantissa
	assign b = {a[31], exp, mant};

endmodule //int2float32

module float2int32(a, b);
	input [31:0] a;
	output [31:0] b;

	reg [30:0] conv;

	assign b = {a[31], conv};

endmodule //float2int32

//Check for highest power of 2 and return just that value, ignore sign
module highestpower32(a, b, rem);
	input [31:0] a;
	output [7:0] b;
	output [31:0] rem;

	wire [30:1] bcalc;
	wire [30:0] remcalc;
	
	generate
		genvar i, j;
		//essentially bcalc[27] = !a[30] & !a[29] & !a[28] & a[27];
		for (i = 29; i > 0; i = i - 1)
		begin:bcalc_loop
			assign bcalc[i] = a[i] & (~|a[30:i+1]);
		end

		//essentially rem[27] = a[27] & (bcalc[30] | bcalc[29] | bcalc[28]);
		for (j = 29; j > -1; j = j - 1)
		begin:remcalc_loop
			assign rem[j] = a[j] & (|bcalc[30:j+1]);
		end
	endgenerate

	assign bcalc[30] = a[30];
	
	assign rem[31] = a[31];
	assign rem[30] = 0;

	//Encoder section
	assign b[7:5] = 3'd0;
	assign b[4] = (|bcalc[30:16]);
	assign b[3] = (|bcalc[30:24]) | (|bcalc[15:8]);
	assign b[2] = (|bcalc[30:28]) | (|bcalc[23:20]) | (|bcalc[15:12]) | (|bcalc[7:4]);
	assign b[1] = bcalc[30] | bcalc[27] | bcalc[26] | bcalc[23] | bcalc[22] | bcalc[19] | bcalc[18] | bcalc[15] | bcalc[14] | bcalc[11] | bcalc[10] | bcalc[7] | bcalc[6] | bcalc[3] | bcalc[2];
	assign b[0] = bcalc[29] | bcalc[27] | bcalc[25] | bcalc[23] | bcalc[21] | bcalc[19] | bcalc[17] | bcalc[15] | bcalc[13] | bcalc[11] | bcalc[9] | bcalc[7] | bcalc[5] | bcalc[3] | bcalc[1];
endmodule //highestpower32