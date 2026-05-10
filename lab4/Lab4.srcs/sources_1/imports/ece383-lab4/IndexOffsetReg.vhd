----------------------------------------------------------------------------------
-- Title: IndexOffsetReg
-- Engineer: 
-- Date:   
-- Description:  Stores a value for the index.offset and increments it by phase_inc 
--   on the rising edge of the clock if en = '1'
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IndexOffsetReg is 
    generic (
        whole_bits : integer := 4;
        frac_bits : integer := 4);
    port ( phase_inc : in std_logic_vector (whole_bits+frac_bits-1 downto 0);
           clk : in STD_LOGIC;
           reset_n : in std_logic;
           en : in STD_LOGIC;
           index_offset : out std_logic_vector(whole_bits+frac_bits-1 downto 0));
end IndexOffsetReg;

architecture IndexOffsetReg_arch of IndexOffsetReg is
    signal index_offset_reg : std_logic_vector (whole_bits+frac_bits-1 downto 0) := (others => '0');
begin

    process (clk)
    begin  
       if (rising_edge(clk)) then
          if reset_n = '0' then
             index_offset_reg <= (others => '0');
          elsif en = '1' then
             index_offset_reg <= std_logic_vector(unsigned(index_offset_reg) + unsigned(phase_inc));
          end if;
       end if;
    end process;

index_offset <= index_offset_reg;

end IndexOffsetReg_arch;