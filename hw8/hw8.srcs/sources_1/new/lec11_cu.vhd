----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2026 01:09:31 PM
-- Design Name: 
-- Module Name: lec11_cu - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lec11_cu is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           kbClk : in STD_LOGIC;
           sw : in STD_LOGIC;
           cw : out STD_LOGIC_VECTOR (3 downto 0);
           busy : out STD_LOGIC);
end lec11_cu;

architecture Behavioral of lec11_cu is

--signal w_cw : std_logic_vector(3 downto 0);
--signal w_sw : std_logic;
type state_t is (waitstart, whilehi_wait, read_in_serial, whilelow_wait, send_parallel);

signal state : state_t := waitstart;

begin

process_fsm : process(clk)
begin

if rising_edge(clk) then
if reset = '0' then state <= waitstart; end if;
case state is
  when waitstart =>
    if kbClk = '0' then state <= whilehi_wait; end if;
    -- elsif = '1' then stay
    -- sw dont care
  when whilehi_wait =>
    if kbClk = '0' then state <= read_in_serial; end if;
  when read_in_serial => 
    -- kbClk should always be LOW by here
    state <= whilelow_wait;
    -- sw don't care
  when whilelow_wait =>
    if kbClk = '0' then state <= whilelow_wait;
    elsif sw = '0' then state <= whilehi_wait;
    elsif sw = '1' then state <= send_parallel; end if;
  when send_parallel =>
    state <= waitstart;
end case;
end if;

end process;

-- assign outputs to states
cw <= "0011" when state = waitstart else
      "0000" when state = whilehi_wait else
      "0101" when state = read_in_serial  else
      "0000" when state = whilelow_wait else
      "1000" when state = send_parallel;
busy <= '0' when state = waitstart else '1';

end Behavioral;
