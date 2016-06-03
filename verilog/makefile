test.o : testbench.v main.v sub-bram.v sub-core.v pe-add.v pe-mean.v pe-product.v pe-sqrt.v pe-square.v
	ls | grep -v makefile | grep -v *_tb.v | grep -v file_list.txt > file_list.txt
	iverilog -o test -c file_list.txt
	vvp test

add : pe-add_tb.v pe-add.v
	iverilog -o test-add pe-add_tb.v pe-add.v
	vvp test-add

clean : 
	rm test 
	rm test-add