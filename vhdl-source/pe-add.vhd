--Adders

--Libraries
library IEEE;
use IEEE.std_logic_1164.all;

--===============ENTITIES===============
entity single_bit_adder is
	port(a, b, cin	: in std_logic;
		sum, cout	: out std_logic);
end entity single_bit_adder;

entity matrix_adder is
	generic(data_size	: integer:= 64);
end entity matrix_adder;

entity discrete_adder is
	generic(data_size	: integer:= 64);
end entity discrete_adder;

--=============ARCHITECTURES============
--Single Bit Adder
architecture beh of single_bit_adder is
begin
	adder:process
	begin
		sum <= (a xor b xor cin) or (a and b and cin);
		cout <= (a and b) or (a and cin) or (b and cin);
	end process adder;
end architecture beh;

--Matrix Adder
architecture beh of matrix_adder is

begin

end architecture beh;

--Discrete Adder
architecture beh of discrete_adder is

begin

end architecture beh;