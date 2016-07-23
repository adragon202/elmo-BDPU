
module mult_test();

    reg [63:0] a, b;
    wire [127:0] mult;

    mult64 m0(a, b, mult);

    initial begin
        a = 64'd 0; b = 64'd 100;
        #1 a = 64'd 1        ; b = 64'd 121241241;
        #1 a = 64'd 264809178; b = 64'd 249197382;
        #1 a = 64'd 794708607; b = 64'd 384975780;
        #1 a = 64'd 676037214; b = 64'd 367867335;
        #1 a = 64'd 100001145; b = 64'd 661311444;
        #1 a = 64'd 584924191; b = 64'd 277229938;
        #1 a = 64'd 15433418 ; b = 64'd 419228883;
        #1 a = 64'd 10580565 ; b = 64'd 816488035;
        #1 a = 64'd 810820786; b = 64'd 734312504;
        #1 a = 64'd 54168466 ; b = 64'd 763379924;
        #1 a = 64'd 143319836; b = 64'd 555598672;

        #3 $stop;
    end 

    initial
        $monitor("At time %t, a(%d) * b(%d) = mult(%d)",
                $time, a, b, mult);

endmodule