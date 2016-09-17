
/*
mult = a * b
Multiplies 64-bit integer values
INPUTS:
    a = 64 bits
    b = 64 bits
OUTPUTS:
    mult = 64 bits
*/
module mult64(a, b, mult);
    localparam VARWIDTH = 64;
    //inputs
    input [VARWIDTH-1:0] a;
    input [VARWIDTH-1:0] b;
    //outputs
    output [VARWIDTH*2-1:0] mult;

    wire [VARWIDTH:0] w[0:VARWIDTH*2-2];

    assign w[0][VARWIDTH-1:0] = (a[0] == 1) ? b : 0;
    assign w[0][VARWIDTH] = 0;

    genvar i;
    generate
        //for loop used to create VARWIDTH-1 adders
        for (i = 0; i<VARWIDTH-1; i=i+1)
        begin : genAdders
            //if current bit of a == 1, then add b to previous sum
            assign w[2*i+1][VARWIDTH-1:0] = (a[i+1] == 1) ? b : 0;
            assign mult[i] = w[2*i][0];
            //create adder
            adder64 adder(.a(w[2*i][VARWIDTH:1]),      
                            .b(w[2*i+1][VARWIDTH-1:0]), 
                            .cin(1'b0), 
                            .sum(w[2*i+2][VARWIDTH-1:0]), 
                            .cout(w[2*i+2][VARWIDTH]));
        end
    endgenerate

    assign mult[VARWIDTH*2-1:VARWIDTH-1] = w[VARWIDTH*2-2];

endmodule //mult64

/*
mult = a * b
Multiplies 32-bit integer values
INPUTS:
    a = 32 bits
    b = 32 bits
OUTPUTS:
    mult = 32 bits
*/
module mult32(a, b, mult);
    localparam VARWIDTH = 32;
    //inputs
    input [VARWIDTH-1:0] a;
    input [VARWIDTH-1:0] b;
    //outputs
    output [VARWIDTH*2-1:0] mult;

    wire [VARWIDTH:0] w[0:VARWIDTH*2-2];

    assign w[0][VARWIDTH-1:0] = (a[0] == 1) ? b : 0;
    assign w[0][VARWIDTH] = 0;

    genvar i;
    generate
        //for loop used to create VARWIDTH-1 adders
        for (i = 0; i<VARWIDTH-1; i=i+1)
        begin : genAdders
            //if current bit of a == 1, then add b to previous sum
            assign w[2*i+1][VARWIDTH-1:0] = (a[i+1] == 1) ? b : 0;
            assign mult[i] = w[2*i][0];
            //create adder
            adder32 adder(.a(w[2*i][VARWIDTH:1]),      
                            .b(w[2*i+1][VARWIDTH-1:0]), 
                            .cin(1'b0), 
                            .sum(w[2*i+2][VARWIDTH-1:0]), 
                            .cout(w[2*i+2][VARWIDTH]));
        end
    endgenerate

    assign mult[VARWIDTH*2-1:VARWIDTH-1] = w[VARWIDTH*2-2];

endmodule //mult32

/*
mult = a * b
Multiplies 24-bit integers
INPUTS:
    a = 24 bits
    b = 24 bits
OUTPUTS:
    mult = 24 bits
*/
module mult24(a, b, mult);
    //inputs
    input [23:0] a;
    input [23:0] b;
    //outputs
    output [47:0] mult;

    wire [24:0] w[0:46];

    assign w[0][23:0] = (a[0] == 1) ? b : 0;
    assign w[0][24] = 0;

    genvar i;
    generate 
        //for loop used to create 23 adders
        for (i = 0; i<23; i=i+1) begin
            //if current bit of a == 1, then add b to previous sum
            assign w[2*i+1][23:0] = (a[i+1] == 1) ? b : 0;
            assign mult[i] = w[2*i][0];
            //create adder
            adder24 adder(.a(w[2*i][24:1]),      
                            .b(w[2*i+1][23:0]), 
                            .cin(1'b0), 
                            .sum(w[2*i+2][23:0]), 
                            .cout(w[2*i+2][24]));
        end
    endgenerate

    assign mult[47:23] = w[46];

endmodule //mult24
