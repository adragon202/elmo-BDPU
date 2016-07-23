
module mult_tb();
	reg [31:0] a,b;
	wire [31:0] mult;

	initial begin 
		a = 32'h40200000; b = 32'h40400000;  // 2.5* 3.0

		#1 a = 32'h3f4f245a; b = 32'h3f34c34a;  // 0.80914843*0.7061049
		#1 a = 32'h3f03ffe8; b = 32'h3ea40f69;  // 0.51562357*0.32043007
		#1 a = 32'h3f3ff224; b = 32'h3e76fe41;  // 0.7497885*0.24120428
		#1 a = 32'h49742400; b = 32'h4cead734;  // 1000000.0*123124128.0
		#1 a = 32'h40400000; b = 32'h00000000;  // 3.0 * 0.0
		#1 a = 32'hbf8ccccd; b = 32'h40a00000;  // -1.1 * 5.0

		#3 $stop;
	end

	mult_float mf(.a(a), .b(b), .m(mult));

    initial
        $monitor("At time %t, a(%d) * b(%d) = mult(%d)",
                $time, a, b, mult);

endmodule 