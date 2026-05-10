----------------------------------------------------------------------------------
-- Title: ResultReg
-- Engineer: 
-- Date:   
-- Description:  Stores a value for the result on the rising edge of the clock if en = '1'
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ResultReg is
    port ( data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (17 downto 0);
           clk : in STD_LOGIC;
           reset_n : in std_logic;
           en : in STD_LOGIC);
end ResultReg;

architecture ResultReg_arch of ResultReg is

begin

    process (clk)
    begin
       if rising_edge(clk) then
          if (reset_n = '0') then
            data_out <= (others => '0');
          elsif en = '1' then
            data_out <= data_in & "00";
          end if;
       end if;
    end process;

end ResultReg_arch;
