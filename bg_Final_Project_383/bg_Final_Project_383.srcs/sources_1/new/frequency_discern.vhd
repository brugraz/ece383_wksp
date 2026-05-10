----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2026 09:45:48 PM
-- Design Name: 
-- Module Name: frequency_discern - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frequency_discern is Port (
  clk : in std_logic;
  reset_n : in std_logic;
  ac_in_L : in STD_LOGIC_VECTOR (15 downto 0);
  ac_in_R : in STD_LOGIC_VECTOR (15 downto 0);
  key : out STD_LOGIC_VECTOR (3 downto 0);
  found : out STD_LOGIC;
  swout : out std_logic_vector(1 downto 0);
  cwout : out std_logic_vector(2 downto 0);
  test_r_max_P : out std_logic_vector(63 downto 0);
  test_c_max_P : out std_logic_vector(63 downto 0));
end frequency_discern;

architecture Behavioral of frequency_discern is

--component cu_frequency_discern is port(
--sw  : in std_logic_vector(2 downto 0);
--cw  : out std_logic_vector(2 downto 0)); end component;
signal  sw     :  std_logic_vector(1 downto 0);
signal  cw     :  std_logic_vector(2 downto 0);

component goertzel is generic(f_target : integer);
port(
clk       : in std_logic;
reset_n   : in std_logic;
x_b16         : in  signed (15 downto 0);
cw        : in std_logic_vector(2 downto 0);
power_out_b64 : out signed (63 downto 0));
end component;
  
component counter is 
generic(
num_bits : integer; max_value : integer);
port(
clk     : in  STD_LOGIC;
reset_n : in  STD_LOGIC;
ctrl    : in  STD_LOGIC;
roll    : out STD_LOGIC;
Q       : out unsigned(num_bits-1 downto 0));
end component;


signal power_697Hz : signed(63 downto 0);
signal power_770Hz : signed(63 downto 0);
signal power_852Hz : signed(63 downto 0);
signal power_941Hz : signed(63 downto 0);

signal power_1209Hz : signed(63 downto 0);
signal power_1336Hz : signed(63 downto 0);
signal power_1477Hz : signed(63 downto 0);
signal power_1633Hz : signed(63 downto 0);

-- for finding max
signal r_max_P : signed(63 downto 0) := (others => '0');
signal c_max_P : signed(63 downto 0) := (others => '0');
signal r_which_max : std_logic_vector(1 downto 0);
signal c_which_max : std_logic_vector(1 downto 0);

-- intermediate temp maxes and "which" trackers
signal r_max_P_697_770 : signed (63 downto 0);
signal r_max_P_852_941 : signed (63 downto 0);
signal r_which_max_697_770 : std_logic_vector (1 downto 0);
signal r_which_max_852_941 : std_logic_vector (1 downto 0);
signal c_max_P_1209_1336 : signed (63 downto 0);
signal c_max_P_1477_1633 : signed (63 downto 0);
signal c_which_max_1209_1336 : std_logic_vector (1 downto 0);
signal c_which_max_1477_1633 : std_logic_vector (1 downto 0);

-- FSM stuff -----------------------------------------------------------------
type state_type is (wait_for_ready, do_s_math, wait_for_s_math_done, count_n, reset_window);
signal state, next_state : state_type;
------------------------------------------------------------------------------

begin
-- calculator governing all 8 modules
window_counter : counter generic map(
  num_bits => 12, max_value => 2063)
  port map(
  clk     => clk,
  reset_n => cw(CW_POWER_CALC_RST),
  ctrl    => cw(CW_COUNT_N),
  roll    => sw(SW_WINDOWFIN),
  Q =>    open
);

-- rows
gtz_697 : goertzel generic map (f_target => Hz_697)
port map (
  clk => clk,
  reset_n => reset_n,
  x_b16 => signed(ac_in_L),
  cw => cw,
  power_out_b64 => power_697Hz
);
gtz_770 : goertzel generic map (f_target => Hz_770)
port map (
  clk => clk,
  reset_n => reset_n,
  x_b16 => signed(ac_in_L),
  cw => cw,
  power_out_b64 => power_770Hz
);
gtz_852 : goertzel generic map (f_target => Hz_852)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_852Hz
);
gtz_941 : goertzel generic map (f_target => Hz_941)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_941Hz
);

-- cols
gtz_1209 : goertzel generic map (f_target => Hz_1209)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_1209Hz
);
gtz_1336 : goertzel generic map (f_target => Hz_1336)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_1336Hz
);
gtz_1477 : goertzel generic map (f_target => Hz_1477)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_1477Hz
);
gtz_1633 : goertzel generic map (f_target => Hz_1633)
port map (
  clk => clk,
  reset_n => reset_n,
  cw => cw,
  x_b16 => signed(ac_in_L),
  power_out_b64 => power_1633Hz
);

process(clk)
begin
if (rising_edge(clk)) then
 -- rows
  -- 697 vs 770
  if power_770Hz > power_697Hz then
    r_max_P_697_770 <= power_770Hz;
    r_which_max_697_770 <= hexid_770;
  else 
    r_max_P_697_770 <= power_697Hz;
    r_which_max_697_770 <= hexid_697;
  end if;
  -- 852 vs 941
  if power_941Hz > power_852Hz then
    r_max_P_852_941 <= power_941Hz;
    r_which_max_852_941 <= hexid_941;
  else
    r_max_P_852_941 <= power_852Hz;
    r_which_max_852_941 <= hexid_852;
  end if;
  
  -- cols
  -- 1209 vs 1336
  if power_1336Hz > power_1209Hz then
    c_max_P_1209_1336 <= power_1336Hz;
    c_which_max_1209_1336 <= hexid_1336;
  else 
    c_max_P_1209_1336 <= power_1209Hz;
    c_which_max_1209_1336 <= hexid_1209;
  end if;
  -- 1477 vs 1633
  if power_1633Hz > power_1477Hz then
    c_max_P_1477_1633 <= power_1633Hz;
    c_which_max_1477_1633 <= hexid_1633;
  else
    c_max_P_1477_1633 <= power_1477Hz;
    c_which_max_1477_1633 <= hexid_1477;
  end if;
  
  -- rows max
  if r_max_P_697_770 > r_max_P_852_941 then
    r_max_P <= r_max_P_697_770;
    r_which_max <= r_which_max_697_770;
  else
    r_max_P <= r_max_P_852_941;
    r_which_max <= r_which_max_852_941;
  end if;
  -- cols max
  if c_max_P_1209_1336 > c_max_P_1477_1633 then
    c_max_P <= c_max_P_1209_1336;
    c_which_max <= c_which_max_1209_1336;
  else
    c_max_P <= c_max_P_1477_1633;
    c_which_max <= c_which_max_1477_1633;
  end if;
  
  
end if;
end process;

  -- check if meets threshold

found <= '1' when c_max_P > x"0000FFFFFFFFFFFF" and r_max_P > x"0000FFFFFFFFFFFF" else '0';
key <= r_which_max & c_which_max; -- convenient, isn't it?

-- testing
swout <= sw;
cwout <= cw;
test_r_max_P <= std_logic_vector(r_max_P);
test_c_max_P <= std_logic_vector(c_max_P);

-- FSM stuff -----------------------------------------------------------------
-- cw(2): calc power
-- cw(1): count n
-- cw(0): do s math for this iteration n
-- sw(2): is sample_ready_ac high?
-- sw(1): is n at ending address?
-- sw(0): s math is done

--sw(SW_S_MATH_DONE) <= '1' when sw8gtz = x"FF" else '0'; -- when all goertzellators are done with their math, sw(this) = '1'



process(clk)
begin
if (rising_edge(clk)) then
  if reset_n = '0' then
    state <= wait_for_ready;
  else 
    state <= next_state;
  end if;
end if;
end process;

next_state <= 
wait_for_ready          when state = wait_for_ready and sw(SW_READY) = '0' else
do_s_math               when state = wait_for_ready and sw(SW_READY) = '1' else
count_n                 when state = do_s_math and sw(SW_WINDOWFIN) = '0' else
reset_window            when state = do_s_math and sw(SW_WINDOWFIN) = '1' else
wait_for_ready          when state = reset_window else
state;

cw <= 
"000" when state = wait_for_ready else
"001" when state = do_s_math else
"010" when state = count_n else
"100" when state = reset_window; 
------------------------------------------------------------------------------

end Behavioral;
