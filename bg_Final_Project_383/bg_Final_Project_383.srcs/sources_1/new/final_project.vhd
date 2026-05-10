----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2026 09:37:24 PM
-- Design Name: 
-- Module Name: final_project - Behavioral
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
library work;
use work.fp_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity final_project is Port (
  switch       : in STD_LOGIC_VECTOR (7 downto 0);
  clk          : in std_logic;
  reset_n      : in std_logic;
  
  ac_mclk      : out std_logic;
  ac_adc_sdata : in std_logic;
  ac_dac_sdata : out std_logic;
  ac_bclk      : out std_logic;
  ac_lrclk     : out std_logic;
  scl          : inout std_logic;
  sda          : inout std_logic;
  
  led          : out STD_LOGIC_VECTOR (7 downto 0);
  
  ja           : out std_logic_vector (7 downto 0)
); end final_project;

architecture Behavioral of final_project is

component frequency_discern is Port(
  clk : in std_logic;
  reset_n : in std_logic;
  ac_in_L : in STD_LOGIC_VECTOR (15 downto 0);
  ac_in_R : in STD_LOGIC_VECTOR (15 downto 0);
  key : out STD_LOGIC_VECTOR (3 downto 0);
  found : out STD_LOGIC;
  swout : out std_logic_vector(1 downto 0);
  cwout : out std_logic_vector(2 downto 0);
  test_r_max_P : out std_logic_vector(63 downto 0);
  test_c_max_P : out std_logic_vector(63 downto 0)
); end component;

component Audio_Codec_Wrapper is Port(
  clk : in STD_LOGIC;
  reset_n : in STD_LOGIC;
  ac_mclk : out STD_LOGIC;
  ac_adc_sdata : in STD_LOGIC;
  ac_dac_sdata : out STD_LOGIC;
  ac_bclk : out STD_LOGIC;
  ac_lrclk : out STD_LOGIC;
  ready : out STD_LOGIC;
  L_bus_in : in std_logic_vector(17 downto 0); -- left channel input to DAC
  R_bus_in : in std_logic_vector(17 downto 0); -- right channel input to DAC
  L_bus_out : out  std_logic_vector(17 downto 0); -- left channel output from ADC
  R_bus_out : out  std_logic_vector(17 downto 0); -- right channel output from ADC
  scl : inout STD_LOGIC;
  sda : inout STD_LOGIC
); end component;

signal sample_ready_ac : std_logic;
signal to_ac_L : std_logic_vector(17 downto 0);
signal to_ac_R : std_logic_vector(17 downto 0);
signal from_ac_L : std_logic_vector(17 downto 0);
signal from_ac_R : std_logic_vector(17 downto 0);

signal sample_L : std_logic_vector(15 downto 0);
signal sample_R : std_logic_vector(15 downto 0);

signal key : std_logic_vector(3 downto 0);
signal found : std_logic;

-- debug
signal cwout : std_logic_vector(2 downto 0);
signal swout : std_logic_vector(1 downto 0);
signal test_r_max_P : std_logic_vector(63 downto 0);
signal test_c_max_P : std_logic_vector(63 downto 0);

begin

Audio_Codec : Audio_Codec_Wrapper port map(
  clk  => clk,
  reset_n => reset_n,
  ac_mclk => ac_mclk,
  ac_adc_sdata => ac_adc_sdata,
  ac_dac_sdata => ac_dac_sdata,
  ac_bclk => ac_bclk,
  ac_lrclk => ac_lrclk,
  ready => sample_ready_ac,
  L_bus_in => to_ac_L,
  R_bus_in => to_ac_R,
  L_bus_out => from_ac_L,
  R_bus_out => from_ac_R,
  scl => scl,
  sda => sda
);

frequency_discern_inst : frequency_discern port map(
  clk => clk,
  reset_n => reset_n,
  ac_in_L => sample_L,
  ac_in_R => sample_R,
  key => key,
  found => found,
  swout => swout,
  cwout => cwout,
  test_r_max_P => test_r_max_P,
  test_c_max_P => test_c_max_P
);

-- loop back audio and save to truncated sample vectors
process (clk)
begin
if (rising_edge(clk)) then
  if reset_n = '0' then
    to_ac_L <= (others => '0');
    to_ac_R <= (others => '0');
  elsif(sample_ready_ac = '1') then
    to_ac_L    <= from_ac_L;
    to_ac_R    <= from_ac_R;
    
 -- keep the values signed !
    sample_L <= from_ac_L(17 downto 2);
    sample_R <= from_ac_R(17 downto 2);
  end if;
end if;
end process;
-- to be considered by the frequency discern module.

-- LED display ASCII in place of T9 for req funct
--led <= UTF8_1 when key = (hexid_697 & hexid_1209) and found = '1' else
--       UTF8_2 when key = (hexid_697 & hexid_1336) and found = '1' else
--       UTF8_3 when key = (hexid_697 & hexid_1477) and found = '1' else
--       UTF8_A when key = (hexid_697 & hexid_1633) and found = '1' else
--       -- row 2
--       UTF8_4 when key = (hexid_770 & hexid_1209) and found = '1' else
--       UTF8_5 when key = (hexid_770 & hexid_1336) and found = '1' else
--       UTF8_6 when key = (hexid_770 & hexid_1477) and found = '1' else
--       UTF8_B when key = (hexid_770 & hexid_1633) and found = '1' else
--       -- row 3
--       UTF8_7 when key = (hexid_852 & hexid_1209) and found = '1' else
--       UTF8_8 when key = (hexid_852 & hexid_1336) and found = '1' else
--       UTF8_9 when key = (hexid_852 & hexid_1477) and found = '1' else
--       UTF8_C when key = (hexid_852 & hexid_1633) and found = '1' else
--       -- row 4
--       UTF8_star when key = (hexid_941 & hexid_1209) and found = '1' else
--       UTF8_0    when key = (hexid_941 & hexid_1336) and found = '1' else
--       UTF8_pnd  when key = (hexid_941 & hexid_1477) and found = '1' else
--       UTF8_D    when key = (hexid_941 & hexid_1633) and found = '1' else
       
--       x"00" when found = '0' else
--       x"FF"; -- error
         
ja(5 downto 3) <= cwout;
ja(2 downto 1) <= swout;
ja(6) <= found;
ja(0) <= clk;

led <= test_C_max_P(63 downto 56);


end Behavioral;
