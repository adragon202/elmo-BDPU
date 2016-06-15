
module mult64(a, b, mult);
//inputs
input [63:0] a;
input [63:0] b;
//outputs
output [127:0] mult;

wire [64:0] w[0:126];

assign w[0][63:0] = (a[0] == 1) ? b : 0;
assign w[0][64] = 0;

genvar i;
generate 
    //for loop used to create 63 adders
    for (i = 0; i<63; i=i+1) begin
        //if current bit of a == 1, then add b to previous sum
        assign w[2*i+1][63:0] = (a[i+1] == 1) ? b : 0;
        assign mult[i] = w[2*i][0];
        //create adder
        adder64 adder(.a(w[2*i][64:1]),      
                        .b(w[2*i+1][63:0]), 
                        .cin(1'b0), 
                        .sum(w[2*i+2][63:0]), 
                        .cout(w[2*i+2][64]));
    end
endgenerate

assign mult[127:63] = w[126];

endmodule
