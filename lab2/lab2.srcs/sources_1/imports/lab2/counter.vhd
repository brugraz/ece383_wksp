----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/21/2026 02:17:36 PM
-- Design Name: 
-- Module Name: counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
 generic(num_bits  : integer := 4;
         max_value : integer := 9);
 port(clk     : in  STD_LOGIC;
      reset_n : in  STD_LOGIC;
      ctrl    : in  STD_LOGIC;
      roll    : out STD_LOGIC;
      Q       : out unsigned(num_bits-1 downto 0));
end counter;

architecture Behavioral of counter is
 signal w_rollSynch : std_logic := '0';
 signal w_processQ  : unsigned(num_bits-1 downto 0) := (others => '0');--to_unsigned(num_bits, 0);
begin
 
process(clk)
 begin 
 if (rising_edge(clk)) then
   if (reset_n = '0') then
     w_processQ  <= (others => '0');
     w_rollSynch <= '0';
   -- if reset = 1
   elsif (w_processQ < max_value-1 and ctrl = '1') then -- increment
     w_rollSynch <= '0';
     w_processQ  <= w_processQ + 1;
   elsif (w_processQ = max_value-1 and ctrl = '1') then -- roll over
     w_rollSynch <= '1'; -- actuated next clk cycle to be read for roll over
     w_processQ  <= w_processQ + 1;  -- get to max value for next cycle
   elsif (w_processQ = max_value and ctrl = '1') then
     w_processQ  <= (others => '0');
     w_rollSynch <= '0';
   end if;
 end if;
end process;
roll <= w_rollSynch;
Q    <= w_processQ;

end Behavioral;
