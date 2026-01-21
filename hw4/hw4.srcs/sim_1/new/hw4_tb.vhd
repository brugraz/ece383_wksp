----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/21/2026 02:19:30 PM
-- Design Name: 
-- Module Name: hw4_tb - Behavioral
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

-- by chatGPT 1/21

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hw4_tb is
end hw4_tb;

architecture sim of hw4_tb is

  -- clock / reset
  signal clk     : std_logic := '0';
  signal reset_n : std_logic := '0';

  -- LSD signals
  signal ctrl_lsd : std_logic := '0';
  signal roll_lsd : std_logic;
  signal Q0       : unsigned(3 downto 0);

  -- MSD signals
  signal ctrl_msd : std_logic;
  signal Q1       : unsigned(3 downto 0);

  constant CLK_PERIOD : time := 10 us;

begin

  --------------------------------------------------------------------
  -- Clock generation
  --------------------------------------------------------------------
  process
  begin
    clk <= not clk;
    wait for CLK_PERIOD/2;
  end process;
  

  --------------------------------------------------------------------
  -- Reset
  --------------------------------------------------------------------
  reset_n <= '0', '1' after 5 us;

  --------------------------------------------------------------------
  -- CSA-style control sequence for LSD
  -- Used to force hold and rollover behavior
  --------------------------------------------------------------------
  ctrl_lsd <=
    '0' after 15 us,  -- normal count
    '1' after 16 us,  -- force rollover
    '0' after 17 us,  -- resume count
    '1' after 18 us;  -- second rollover edge (for visibility)

  --------------------------------------------------------------------
  -- Least Significant Digit Counter
  --------------------------------------------------------------------
  lsd_counter : entity work.counter
    generic map (
      num_bits  => 4,
      max_value => 9
    )
    port map (
      clk     => clk,
      reset_n => reset_n,
      ctrl    => ctrl_lsd,
      roll    => roll_lsd,
      Q       => Q0
    );

  --------------------------------------------------------------------
  -- Cascade connection
  --------------------------------------------------------------------
  ctrl_msd <= roll_lsd;

  --------------------------------------------------------------------
  -- Most Significant Digit Counter
  --------------------------------------------------------------------
  msd_counter : entity work.counter
    generic map (
      num_bits  => 4,
      max_value => 9
    )
    port map (
      clk     => clk,
      reset_n => reset_n,
      ctrl    => ctrl_msd,
      roll    => open,
      Q       => Q1
    );

end sim;
