----------------------------------------------------------------------------------
--	Title
--  Name
--  Description
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity lab1 is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
		   btn: in	STD_LOGIC_VECTOR(4 downto 0);
		   led: out STD_LOGIC_VECTOR(4 downto 0);
		   sw: in STD_LOGIC_VECTOR(1 downto 0);
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0));
end lab1;

architecture structure of lab1 is

  constant CENTER : integer := 4;
  constant DOWN : integer := 2;
  constant LEFT : integer := 1;
  constant RIGHT : integer := 3;
  constant UP : integer := 0;

  constant PX_MIN_GRID_VOLT : integer := 20;
  constant PX_MAX_GRID_VOLT : integer := 420;
  constant PX_MIN_GRID_TIME : integer := 20;
  constant PX_MAX_GRID_TIME : integer := 620;
  constant px_btwn_hashes_volt : integer := 10;
  constant px_btwn_hashes_time : integer := 15;
  -- generic values
  constant STEPPER_NUM_BITS : integer := 11;

  constant STEPPER_VOLT_bottomofscr : integer := PX_MAX_GRID_VOLT;
  constant STEPPER_volt_topofscr    : integer := px_min_grid_volt;
  constant STEPPER_volt_DELTA       : integer := px_btwn_hashes_volt;
  constant stepper_time_rightofscr  : integer := px_max_grid_time;
  constant stepper_time_leftofscr   : integer := px_min_grid_time;
  constant stepper_time_delta       : integer := px_btwn_hashes_time;

  constant stepper_volt_init_val    : integer := 220;
  constant stepper_time_init_val    : integer := 320;

  constant yint_ch2                 : integer := 440;

  signal trigger: trigger_t;
	signal pixel: pixel_t;
	signal ch1, ch2: channel_t;
  signal time_trigger_value, volt_trigger_value : signed(STEPPER_NUM_BITS-1 downto 0);

  signal w_btn : std_logic_vector(4 downto 0);

begin

-- Add numeric steppers for time and voltage trigger
stepper_volt : numeric_stepper
generic map(
num_bits   => STEPPER_NUM_BITS,
max_value  => stepper_volt_bottomofscr,
min_value  => stepper_volt_topofscr,
delta      => stepper_volt_delta,
init_val   => stepper_volt_init_val
)
port map(
clk     => clk,
reset_n => reset_n,
en      => '1', -- no trigger settings lock, always enable
up      => w_btn(DOWN), -- larger Q -> lower on screen, press the "down" button
down    => w_btn(UP),   -- smaller Q -> higher on screen, press the "up" button
q       => volt_trigger_value
);

stepper_time : numeric_stepper
generic map(
num_bits   => STEPPER_NUM_BITS,
max_value  => stepper_time_rightofscr,
min_value  => stepper_time_leftofscr,
delta      => stepper_time_delta,
init_val   => stepper_time_init_val
)
port map(
clk     => clk,
reset_n => reset_n,
en      => '1', -- no trigger settings lock, always enable
up      => w_btn(RIGHT),
down    => w_btn(LEFT),
q       => time_trigger_value
);

w_btn <= btn;

-- Assign trigger.t and trigger.v
trigger.t <= unsigned(time_trigger_value);
trigger.v <= unsigned(volt_trigger_value);
       	
-- Instantiate video
video_inst : video
port map(
  clk    => clk,
  reset_n => reset_n,
  tmds    => tmds,
  tmdsb   => tmdsb,
  trigger => trigger,
  position => pixel.coordinate,
  ch1      => ch1,
  ch2      => ch2
);
-- Determine if ch1 and or ch2 are active
ch1.active <= '1' when pixel.coordinate.row = pixel.coordinate.col else '0';
ch2.active <= '1' when pixel.coordinate.row = yint_ch2-pixel.coordinate.col else '0';
-- Connect board hardware to signals
ch1.en <= sw(1);
ch2.en <= sw(0);

led <= "00000";

	
end structure;
