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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hw3_tb is
end hw3_tb;

architecture tb of hw3_tb is
    signal d : unsigned(7 downto 0);
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
        -- Exhaustive test of all 8-bit values
        for i in 0 to 255 loop
            d <= to_unsigned(i, 8);
            wait for 10 ns;

            upper_nibble := d(7 downto 4);
            lower_nibble := d(3 downto 0);

            if upper_nibble = lower_nibble then
                assert h = '1'
                    report "FAIL: expected h = 1"
                    severity error;
            else
                assert h = '0'
                    report "FAIL: expected h = 0"
                    severity error;
            end if;
        end loop;

        wait;
    end process;

end tb;
