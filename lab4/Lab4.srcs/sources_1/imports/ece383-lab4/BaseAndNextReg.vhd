----------------------------------------------------------------------------------
-- Title: BaseAndNextReg
-- Engineer: 
-- Date:   
-- Description: Contains two registers, one for the base value and one for the next value, with
--  separate enables and a shared input.  reset_n is a synchronous reset that resets both registers.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BaseAndNextReg is
    generic (
        data_size : natural := 16);
    port ( data_in : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           base_en : in STD_LOGIC;
           next_en : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset_n : in std_logic;
           base_out : out STD_LOGIC_VECTOR (data_size-1 downto 0);
           next_out : out STD_LOGIC_VECTOR (data_size-1 downto 0));
end BaseAndNextReg;

architecture BaseAndNextReg_arch of BaseAndNextReg is
    signal base_reg, next_reg : std_logic_vector (data_size-1 downto 0) := (others => '0');
begin

    process (clk)
    begin  
       if (rising_edge(clk)) then
          if reset_n = '0' then
             base_reg <= (others => '0');
             next_reg <= (others => '0');
          else
            if base_en = '1' then
                base_reg <= data_in;
            end if;
            if next_en = '1' then
                next_reg <= data_in;
            end if;
          end if;
       end if;
    end process;
    
base_out <= base_reg;
next_out <= next_reg;

end BaseAndNextReg_arch;
