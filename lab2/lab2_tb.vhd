----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2026 01:12:09 PM
-- Design Name: 
-- Module Name: lab2_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;	
use work.ece383_pkg.all;

entity lab2_tb is
end lab2_tb;

architecture Behavioral of lab2_tb is

 component lab2
     Port ( clk : in  STD_LOGIC;
            reset_n : in  STD_LOGIC;
		    ac_mclk : out STD_LOGIC;
		    ac_adc_sdata : in STD_LOGIC;
		    ac_dac_sdata : out STD_LOGIC;
		    ac_bclk : out STD_LOGIC;
		    ac_lrclk : out STD_LOGIC;
            scl : inout STD_LOGIC;
            sda : inout STD_LOGIC;
		    tmds : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
		    switch: in	STD_LOGIC_VECTOR(3 downto 0);
		    btn: in	STD_LOGIC_VECTOR(4 downto 0));
end component;

signal sim_switch : std_logic_vector(3 downto 0);
signal sim_btn : std_logic_vector(4 downto 0);
signal reset_n : std_logic;
signal clk : std_logic;
signal data : std_logic;
--signal s_led : std_logic_vector(7 downto 1) := "0000000";

constant clk_period : time := 10 ns;
constant data_period : time := 29 ns;

begin
    uut : lab2
    PORT MAP (
        clk => clk,
        reset_n => reset_n,
        ac_mclk => open,
        ac_adc_sdata => data,
        ac_dac_sdata => open,
        ac_bclk => open,
        ac_lrclk => open,
        scl => open,
        tmds => open,
        tmdsb => open,
        switch => sim_switch,
        btn => sim_btn
    );
    
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
   
   data_process :process
   begin
		data <= '0';
		wait for data_period/2;
		data <= '1';
		wait for data_period/2;
   end process;
    
    reset_n <= '0', '1' after 10 ns;
    sim_switch <= "0100", "0111" after 10ns;
    sim_btn(UP) <= '0', '1' after 10 ns, '0' after 15 ns;
    
    
    

end Behavioral;
