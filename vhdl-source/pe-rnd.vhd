-- pe-rnd 	A true Random Number Generator, used to optimize the process of random number generation
--			Number produced is truely random as it is not an element of time.

--Libraries
library IEEE;
use IEEE.std_logic_1164.all;

entity rnd is
	port(x : in std_logic;
		A : out std_logic);
end entity;

architecture beh of rnd is
	signal Afdbck: std_logic;
begin
	rand:process
	begin
		Afdbck <= not (not ((not x and Afdbck) or (x and not Afdbck)));
		A <= Afdbck;
	end process;
end architecture;