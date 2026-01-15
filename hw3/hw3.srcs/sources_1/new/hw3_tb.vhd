----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 05:52:30 PM
-- Design Name: 
-- Module Name: hw3_tb - Behavioral
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
-- by chatGPT 1/14
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


entity hw3_tb is
end hw3_tb;

architecture tb of hw3_tb is
    signal d : std_logic_vector(7 downto 0);
    signal h : std_logic;
begin

    -- Unit under test
    uut: entity work.hw3
        port map (
            d => d,
            h => h
        );

    stimulus: process
        variable upper_nibble : unsigned(3 downto 0);
        variable lower_nibble : unsigned(3 downto 0);
    begin
        -- Exhaustively test all 8-bit inputs
        for i in 0 to 255 loop
            d <= std_logic_vector(to_unsigned(i, 8));
            wait for 10 ns;

            upper_nibble := unsigned(d(7 downto 4));
            lower_nibble := unsigned(d(3 downto 0));

            if upper_nibble = lower_nibble then
                assert h = '1'
                    report "FAIL: expected h=1 for d=" & integer'image(i)
                    severity error;
            else
                assert h = '0'
                    report "FAIL: expected h=0 for d=" & integer'image(i)
                    severity error;
            end if;
        end loop;

        -- End simulation
        wait;
    end process;

end tb;
