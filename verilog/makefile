test.o : testbench.v main.v sub-bram.v sub-core.v pe-add.v pe-mean.v pe-product.v pe-sqrt.v pe-square.v
	ls | grep -v makefile | grep -v *_tb.v | grep -v test-* | grep -v file_list.txt > file_list.txt
	iverilog -o test-full -c file_list.txt
	echo finish | vvp test

add : pe-add_tb.v pe-add.v
	iverilog -o test-add pe-add_tb.v pe-add.v
	echo finish | vvp test-add

addfloat : pe-add.v pe-addFloat.v
	iverilog -o test-addfloat pe-addFloat_tb.v pe-add.v pe-addFloat.v
	echo finish | vvp test-addfloat

divide : pe-divide_tb.v pe-divide.v pe-float.v pe-add.v
	iverilog -o test-divide pe-divide_tb.v pe-divide.v pe-float.v pe-add.v
	echo finish | vvp test-divide

multiply : pe-multiplier_tb.v pe-multiplier.v pe-add.v
	iverilog -o test-multiply pe-multiplier_tb.v pe-multiplier.v pe-add.v
	echo finish | vvp test-multiply

multfloat : pe-multFloat_tb.v pe-multFloat.v pe-add.v pe-mux.v pe-multiplier.v
	iverilog -o test-multfloat pe-multFloat_tb.v pe-multFloat.v pe-add.v pe-mux.v pe-multiplier.v
	echo finish | vvp test-multfloat

float : pe-float_tb.v pe-float.v pe-add.v
	iverilog -o test-float pe-float_tb.v pe-float.v pe-add.v
	echo finish | vvp test-float

simpletest : test-simple_tb.v
	iverilog -o test-simple test-simple_tb.v
	echo finish | vvp test-simple

clean : 
	rm test-*