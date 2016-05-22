test.o : testbench.v main.v sub-bram.v sub-core.v pe-add.v pe-mean.v pe-product.v pe-sqrt.v pe-square.v
	ls | grep -v makefile | grep -v file_list.txt > file_list.txt
	iverilog -o test -c file_list.txt
	vvp test
