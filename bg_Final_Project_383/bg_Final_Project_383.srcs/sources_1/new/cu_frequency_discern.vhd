----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2026 10:01:41 PM
-- Design Name: 
-- Module Name: cu_frequency_discern - Behavioral
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

entity cu_frequency_discern is
    Port ( sw : in STD_LOGIC_VECTOR (2 downto 0);
           cw : out STD_LOGIC_VECTOR (2 downto 0));
end cu_frequency_discern;

architecture Behavioral of cu_frequency_discern is

begin


end Behavioral;
