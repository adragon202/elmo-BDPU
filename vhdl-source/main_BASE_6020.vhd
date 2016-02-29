-- main 	Top level of design, incorporating all other modules in some degree

--Libraries
library IEEE;
use IEEE.std_logic_1164.all;

entity main is
	generic(data_pins	: integer:= 64;
			opcode_size	: integer:= 8;
			core_count	: integer:= 4);
	port(clk	: in std_logic;
		opcode	: in std_logic_vector(opcode_size-1 downto 0);
		data_in	: in std_logic_vector(data_pins-1 downto 0);
		data_out: out std_logic_vector(data_pins-1 downto 0));
end entity main;

architecture main_a of main is

begin
	core_1: WORK.sub_core generic map()
			port map();
	bram:	WORK.sub_bram generic map()
			port map();
	run: process(clk)
	begin

	end process;
end architecture main_a;
