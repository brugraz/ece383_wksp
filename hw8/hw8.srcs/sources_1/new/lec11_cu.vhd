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
           cw : in STD_LOGIC_VECTOR (3 downto 0);
           busy : in STD_LOGIC);
end lec11_cu;

architecture Behavioral of lec11_cu is

signal cw : std_logic_vector(3 downto 0);
signal sw : std_logic;
type state_t is (waitstart, loopcond, gathershift, scanout);

signal state : state_t := waitstart;

begin

process_fsm : process(clk)
begin

if rising_edge(clk) then
if reset = '0' then state <= waitstart; end if;
case state is
  when waitstart =>
    if kbClk = '0' then state <= loopcond; end if;
  when loopcond =>
    if kbClk = '0' then state <= gathershift; end if;
  when gathershift =>
    if kbClk = '0' then state <= gathershift;
    elsif sw = '0' then state <= loopcond;
    elsif sw = '1' then state <= scanout;
    end if;
  when scanout =>
    if busy = '0' then state <= waitstart; end if;
end case;
end if;

end process;

-- assign outputs to states

end Behavioral;
