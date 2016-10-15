#!/usr/bin/python3
# Usage: ./convertraw2test.py <input filename> <output filename>
# Converts the data file of vectors to verilog input for testbenches

import sys

# Validate Input Parameters
# print(len(sys.argv))
if len(sys.argv) < 3:
	exit()

def main(filein, fileout):
	veccount = 0
	index = 0
	outstr = ""
	# Read file and format output string
	fi = open(filein, 'r')
	for line in fi:
		vec = line.split(' ')
		outstr += "vectors[" + str(index) + "] = " + str(veccount) + ";\n"
		index += 1
		valcount = 0
		for val in vec:
			outstr += "vectors[" + str(index) + "] = " + val.split('\n')[0] + ";\n"
			valcount += 1
			index += 1
		veccount += 1
	# Prepend vector stats
	outstr = "vectorwidth = " + str(valcount) + ";\n" + outstr
	outstr = "vectorcount = " + str(veccount) + ";\n" + outstr
	# Write output string to file
	# print(outstr)
	fi.close()
	fo = open(fileout, 'w')
	fo.write(outstr)
	fo.close()

main(sys.argv[1], sys.argv[2])