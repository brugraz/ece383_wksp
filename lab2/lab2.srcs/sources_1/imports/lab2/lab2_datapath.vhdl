------------------------------------------------------------------------------------------
-- Lab2 Datapath: Implements hardware for storing samples from the audio codec into BRAM
--  and then displaying those samples from BRAM via VGA->HDMI.
-- Lt Col James Trimble, 11Feb2025
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;	
library UNISIM;
use UNISIM.VComponents.all;
use work.ece383_pkg.all;

entity lab2_datapath is Port (
  clk                : in    STD_LOGIC;
	reset_n            : in    STD_LOGIC;
  ac_mclk            : out   STD_LOGIC;
  ac_adc_sdata       : in    STD_LOGIC;
  ac_dac_sdata       : out   STD_LOGIC;
  ac_bclk            : out   STD_LOGIC;
  ac_lrclk           : out   STD_LOGIC;
  scl                : inout STD_LOGIC;
  sda                : inout STD_LOGIC;    
  tmds               : out   STD_LOGIC_VECTOR(3 downto 0);
  tmdsb              : out   STD_LOGIC_VECTOR(3 downto 0);
  sw                 : out   std_logic_vector(2 downto 0);
  cw                 : in    std_logic_vector(2 downto 0);
  btn                : in    STD_LOGIC_VECTOR(4 downto 0);
  switch             : in    STD_LOGIC_VECTOR(3 downto 0);
  exWrAddr           : in    std_logic_vector(RDWRADDR_WIDTH-1 downto 0);
  exWen, exSel       : in    std_logic;
  Lbus_out, Rbus_out : out   std_logic_vector(READWRITE_WIDTH-1 downto 0);
  exLbus, exRbus     : in    std_logic_vector(READWRITE_WIDTH-1 downto 0);
  flagQ              : out   std_logic;   
  flagClear          : in    std_logic;
  dp_led             : out   std_logic_vector(4 downto 0);
  writeCntr_dbg : out unsigned(RDWRADDR_WIDTH-1 downto 0));
end lab2_datapath;

architecture lab2_datapath_arch of lab2_datapath is
 
component BRAM_macro_wrapper is 
Generic(
  wrap_RW_WIDTH     : integer := READWRITE_WIDTH;
  wrap_RWADDR_WIDTH : integer := RDWRADDR_WIDTH);
Port(
  wrap_DATAOUT : OUT std_logic_vector(wrap_RW_WIDTH-1 downto 0);
  wrap_RDADDR  : IN  std_logic_vector(wrap_RWADDR_WIDTH-1 downto 0);-- Input address, width defined by port depth
  wrap_RW_CLK  : IN  std_logic;                   -- 1-bit input clock
  wrap_RST     : IN  std_logic;                   -- active high reset
  wrap_DATAIN  : IN  std_logic_vector(wrap_RW_WIDTH-1 downto 0) := (others=>'0');                   -- Input data port, width defined by WRITE_WIDTH parameter
  wrap_WRADDR  : IN  std_logic_vector(wrap_RWADDR_WIDTH-1 downto 0);           -- Input write address, width defined by write port depth
  wrap_WREN    : IN  std_logic);
end component;
 
component Audio_Codec_Wrapper Port (
  clk          : in    STD_LOGIC;
  reset_n      : in    STD_LOGIC;
  ac_mclk      : out   STD_LOGIC;
  ac_adc_sdata : in    STD_LOGIC;
  ac_dac_sdata : out   STD_LOGIC;
  ac_bclk      : out   STD_LOGIC;
  ac_lrclk     : out   STD_LOGIC;
  ready        : out   STD_LOGIC;
  L_bus_in     : in    std_logic_vector(AC_BUS_WIDTH-1 downto 0); -- left channel input to DAC
  R_bus_in     : in    std_logic_vector(AC_BUS_WIDTH-1 downto 0); -- right channel input to DAC
  L_bus_out    : out   std_logic_vector(AC_BUS_WIDTH-1 downto 0); -- left channel output from ADC
  R_bus_out    : out   std_logic_vector(AC_BUS_WIDTH-1 downto 0); -- right channel output from ADC
  scl          : inout STD_LOGIC;
  sda          : inout STD_LOGIC;
  sim_live     : in    STD_LOGIC);   --  '0' simulate audio; '1' live audio
end component;

component lec10 is -- for address counter
Generic(
  N     : integer := RDWRADDR_WIDTH);
Port(
  clk     : in  STD_LOGIC;
  reset_n : in  STD_LOGIC;
  ctrl    : in  STD_LOGIC_VECTOR(1 downto 0);
  D       : in  unsigned(N-1 downto 0);
  Q       : out unsigned(N-1 downto 0));
end component;

component button_debounce is Port(
	clk      : in  STD_LOGIC;
  reset_n  : in  STD_LOGIC;
  button   : in  STD_LOGIC;
  action   : out STD_LOGIC);
end component;

signal debutton_UP, debutton_LEFT, debutton_DOWN, debutton_RIGHT, debutton_CENTER : std_logic;
  
signal sw_ready           : std_logic := '0';
signal sw_last_address    : std_logic := '0';
signal sw_trigger         : std_logic := '1'; -- hard code until trig set up

signal cw_counter_control : std_logic_vector(1 downto 0);
signal cw_write_en        : std_logic := '0';
signal wren_bram          : std_logic;

signal counter_reset      : std_logic;
signal ch1, ch2           : channel_t;
signal is_live            : std_logic;
signal trigger            : trigger_t;
signal num_stepper_t, num_stepper_v : signed(10 downto 0);
signal writeCntr          : unsigned(RDWRADDR_WIDTH-1 downto 0);
signal position           : coordinate_t;
signal reset              : std_logic;   
signal write_address      : unsigned(RDWRADDR_WIDTH-1 downto 0);
signal current_sample_trunc : unsigned(RDWRADDR_WIDTH-1 downto 0);

constant CENTER_COLUMN            : integer := 320;
constant CENTER_ROW               : integer := 220;
constant HASH_SIZE                : integer := 1;
constant HASH_HORIZONTAL_SPACING  : integer := 15;
constant HASH_VERTICAL_SPACING    : integer := 10;
constant GRID_START_ROW           : integer := 20;
constant GRID_STOP_ROW            : integer := 420;
constant GRID_START_COL           : integer := 20;
constant GRID_STOP_COL            : integer := 620;

constant STEPPER_NUM_BITS         : integer := RDWRADDR_WIDTH+1; -- trig stepper is 11 bits

constant STEPPER_VOLT_bottomofscr : integer := GRID_STOP_ROW;
constant STEPPER_volt_topofscr    : integer := GRID_START_ROW;
constant STEPPER_volt_DELTA       : integer := HASH_VERTICAL_SPACING;
constant stepper_time_rightofscr  : integer := GRID_STOP_COL;
constant stepper_time_leftofscr   : integer := GRID_START_COL;
constant stepper_time_delta       : integer := HASH_HORIZONTAL_SPACING;

constant stepper_volt_init_val    : integer := CENTER_ROW;
constant stepper_time_init_val    : integer := CENTER_COLUMN;
  
begin

-- Determine if the current row matches the stored data from BRAM which means the channel should be active (drawn)
ch1.active <= '1' when position.row = 
 apply_offset('0' & ch1.from_bram(
 READWRITE_WIDTH-1 downto READWRITE_WIDTH-RDWRADDR_WIDTH+1)); -- /2 to scale into 512 height not 1024, hence the & '0' and + 1 place
ch2.active <= '1' when position.row = 
 apply_offset('0' & ch2.from_bram(
 READWRITE_WIDTH-1 downto READWRITE_WIDTH-RDWRADDR_WIDTH+1));
 -- apply_offset was changed to give effect AFTER scaling ch1/2 

-------------------------------------------------------------------------------
--  Buffer a copy of the sample memory to look for positive trigger crossing
--  "Loop back" digitized audio input to the output to confirm interface is working
-------------------------------------------------------------------------------
process (clk)
begin
if (rising_edge(clk)) then
  if reset_n = '0' then
    ch1.to_ac <= (others => '0');
    ch2.to_ac <= (others => '0');
  elsif(sw_ready = '1') then
    ch1.to_ac    <= ch1.from_ac;
    ch2.to_ac    <= ch2.from_ac;
    ch1.incoming_sample <= ch1.from_ac( -- kick off least significant 2 bits
     AC_BUS_WIDTH-1 downto AC_BUS_WIDTH-READWRITE_WIDTH); -- make 17 downto 2 instead o
    ch2.incoming_sample <= ch2.from_ac(
     AC_BUS_WIDTH-1 downto AC_BUS_WIDTH-READWRITE_WIDTH);
  end if;
end if;
end process;

-- Convert Signed sample from Codec into an unsigned value
ch1.current_sample <= make_unsigned(ch1.incoming_sample);
ch2.current_sample <= make_unsigned(ch2.incoming_sample);
  
-- Send the unsigned current sample to the BRAM
ch1.to_bram <= ch1.current_sample when exSel = '0' else exLBus;
ch2.to_bram <= ch2.current_sample when exSel = '0' else exRBus;

-- Need logic for the FLAG register
process (clk)
begin
if (rising_edge(clk)) then
  if sw_ready = '1' then
    flagQ <= '1';
  elsif(flagClear = '1') then
    flagQ <= '0';
  end if;
end if;
end process;

  ------------------------------------------------------------------------------
-- If a button has been pressed then increment or decrement the trigger time and Volt
--    should this be debounced?
debouncer_UP : button_debounce Port map(
	clk      => clk,
  reset_n  => reset_n,
  button   => btn(UP),
  action   => debutton_UP
);
debouncer_LEFT : button_debounce Port map(
	clk      => clk,
  reset_n  => reset_n,
  button   => btn(LEFT),
  action   => debutton_LEFT
);
debouncer_DOWN : button_debounce Port map(
	clk      => clk,
  reset_n  => reset_n,
  button   => btn(DOWN),
  action   => debutton_DOWN
);
debouncer_RIGHT : button_debounce Port map(
	clk      => clk,
  reset_n  => reset_n,
  button   => btn(RIGHT),
  action   => debutton_RIGHT
);
debouncer_CENTER : button_debounce Port map(
	clk      => clk,
  reset_n  => reset_n,
  button   => btn(CENTER),
  action   => debutton_CENTER
);

------------------------------------------------------------------------------
-- Add numeric steppers for time and voltage trigger
stepper_volt : numeric_stepper
generic map(
  num_bits   => STEPPER_NUM_BITS, -- 11 bits
  max_value  => stepper_volt_bottomofscr,
  min_value  => stepper_volt_topofscr,
  delta      => stepper_volt_delta,
  init_val   => stepper_volt_init_val
)
port map(
  clk     => clk,
  reset_n => reset_n,
  en      => '1', -- no trigger settings lock, always enable
  up      => debutton_DOWN, -- larger Q -> lower on screen, press the "down" button
  down    => debutton_UP,   -- smaller Q -> higher on screen, press the "up" button
  q       => num_stepper_v
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
  up      => debutton_RIGHT,
  down    => debutton_LEFT,
  q       => num_stepper_t
);

-------------------------------------------------------------------------------
-- Address counter for RAM
-- What range of addresses does it need to span?  Should it start at zero or something else?
-- How high should it count?  Will it go to its start value on reset or load?
-------------------------------------------------------------------------------
-- Add code here.  Use a previously built counter.
address_counter : lec10
Generic map(
  N => RDWRADDR_WIDTH
)
Port map(
  clk     => clk,
  reset_n => reset_n,
  ctrl    => cw_counter_control,
  D       => to_unsigned(GRID_START_COL, RDWRADDR_WIDTH),
  Q       => writeCntr
);

-- logic to count the write address (columns incrementing)
sw(bit_SW_LASTADDR) <= '1' when writeCntr = TO_UNSIGNED(GRID_STOP_COL, RDWRADDR_WIDTH) else '0'; -- it's 620 in decimal

writeCntr_dbg <= writeCntr;

write_address <= writeCntr when exSel = '0' else unsigned(exWrAddr);

-------------------------------------------------------------------------------
-- Triggering Logic: A positive crossing of the trigger occurs when the previous value is 
--	less than the trigger and the current value is greater than or equal to
-- the trigger.  Set the status word to alert the FSM that it should start 
-- recording the samples.
current_sample_trunc <= unsigned(apply_offset('0' & ch1.current_sample(READWRITE_WIDTH-1 downto 7))); 
-- unsigned(apply_offset('0' & ch1.current_sample(READWRITE_WIDTH-1 downto 7))), --unsigned(ch1.current_sample(READWRITE_WIDTH-1 downto 6)),
-------------------------------------------------------------------------------		
trig_detect_ch1 : trigger_detector Port map (
  clk              => clk,
  reset_n          => reset_n,
  threshold        => trigger.v(TRIGGERLOC_WIDTH-1 downto 1),
  ready            => sw_ready,
  monitored_signal => current_sample_trunc,
  crossed_trigger  => sw_trigger
);

-------------------------------------------------------------------------------
-- Instantiate the video driver from Lab1 - should integrate smoothly
-------------------------------------------------------------------------------
video_inst: video Port map( 
  clk      => clk,
  reset_n  => reset_n,
  tmds     => tmds,
  tmdsb    => tmdsb,
  trigger  => trigger,
  position => position,
  ch1      => ch1, 
  ch2      => ch2
); 

Audio_Codec : Audio_Codec_Wrapper Port map (
  clk => clk,
  reset_n => reset_n, 
  ac_mclk => ac_mclk,
  ac_adc_sdata => ac_adc_sdata,
  ac_dac_sdata => ac_dac_sdata,
  ac_bclk => ac_bclk,
  ac_lrclk => ac_lrclk,
  ready => sw_ready,
  L_bus_in  => ch1.to_ac,   -- left channel input to DAC
  R_bus_in  => ch2.to_ac,   -- right channel input to DAC
  L_bus_out => ch1.from_ac, -- left channel output from ADC
  R_bus_out => ch2.from_ac, -- right channel output from ADC
  scl => scl,
  sda => sda,
  sim_live => is_live
);  --  '0' simulate audio; '1' live audio

leftChannelMemory : BRAM_macro_wrapper
Generic map(
  wrap_RW_width     => READWRITE_WIDTH,
  wrap_RWADDR_WIDTH => RDWRADDR_WIDTH)
Port map(
  wrap_DATAOUT => ch1.from_bram,
  wrap_RDADDR  => std_logic_vector(position.col), -- Input address, width defined by port depth
  wrap_RW_CLK  => clk,                            -- 1-bit input clock
  wrap_RST     => reset,                          -- active high reset
  wrap_DATAIN  => ch1.to_bram,                    -- Input data port, width defined by WRITE_WIDTH parameter
  wrap_WRADDR  => std_logic_vector(write_address),                  -- Input write address, width defined by write port depth
  wrap_WREN    => wren_bram
);

rightChannelMemory : BRAM_macro_wrapper
Generic map(
  wrap_RW_WIDTH     => READWRITE_WIDTH, 
  wrap_RWADDR_WIDTH => RDWRADDR_WIDTH) 
Port map(
  wrap_DATAOUT => ch2.from_bram,
  wrap_RDADDR  => std_logic_vector(position.col),  -- Input address, width defined by port depth
  wrap_RW_CLK  => clk,                             -- 1-bit input clock
  wrap_RST     => reset,                           -- active high reset
  wrap_DATAIN  => ch2.to_bram,                     -- Input data port, width defined by WRITE_WIDTH parameter
  wrap_WRADDR  => std_logic_vector(write_address), --Input write address, width defined by write port depth
  wrap_WREN    => wren_bram
);

-- concurrent

wren_bram <= cw_write_en when exSel = '0' else exWen;

-- outputs and in

trigger.t <= unsigned(num_stepper_t);
trigger.v <= unsigned(num_stepper_v);

reset <= not reset_n;

sw(bit_SW_READY)    <= sw_ready;
sw(bit_SW_LASTADDR) <= sw_last_address;
sw(bit_SW_TRIG)     <= sw_trigger;

cw_counter_control <= cw(1 downto 0);
cw_write_en        <= cw(bit_CW_WREN);
  
ch1.en  <= switch(CH1_SWITCH);
ch2.en  <= switch(CH2_SWITCH);
is_live <= switch(SIM_LIVE_SWITCH);  -- '0' simulate audio; '1' live audio
  
dp_led <= is_live & "0000";
  
end lab2_datapath_arch;

