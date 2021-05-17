-- this file is similar to Lab 2's leddec.vhd found here: https://github.com/kevinwlu/dsd/blob/master/Nexys-A7/Lab-2/leddec.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_lut is

   port (
          dig_in     : in  std_logic_vector(3 downto 0);
          seg_out    : out std_logic_vector(6 downto 0)
          --data   : in std_logic_vector(4 downto 0); -- added these two for future use
          --anode  : out std_logic_vector(7 downto 0)
         
        );
end entity seg7_lut;

architecture syn of seg7_lut is

begin
   -- selects which hex digit to display based on the value of dig_in
   with dig_in select
      seg_out <= "1111001" when "0001",
                 "0100100" when "0010",
                 "0110000" when "0011",
                 "0011001" when "0100",
                 "0010010" when "0101",
                 "0000010" when "0110",
                 "1111000" when "0111",
                 "0000000" when "1000",
                 "0011000" when "1001",
                 "0001000" when "1010",
                 "0000011" when "1011",
                 "1000110" when "1100",
                 "0100001" when "1101",
                 "0000110" when "1110",
                 "0001110" when "1111",
                 "1000000" when "0000";

end architecture syn;
