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
  clk : in  STD_LOGIC;
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
  sw: out std_logic_vector(2 downto 0);
  cw: in std_logic_vector (2 downto 0);
  btn: in    STD_LOGIC_VECTOR(4 downto 0);
  switch: in    STD_LOGIC_VECTOR(3 downto 0);
  exWrAddr: in std_logic_vector(9 downto 0);
  exWen, exSel: in std_logic;
  Lbus_out, Rbus_out: out std_logic_vector(15 downto 0);
  exLbus, exRbus: in std_logic_vector(15 downto 0);
  flagQ: out std_logic;   
  flagClear: in std_logic); 
end lab2_datapath;

architecture lab2_datapath_arch of lab2_datapath is
   
  component BRAM_macro_cage is 
  Generic(
    caged_RW_width : integer := 16;
    caged_pos_bitwidth : integer := 11);
  Port(
    caged_DATAOUT : OUT std_logic_vector(caged_RW_WIDTH-1 downto 0);
    caged_RDADDR  : IN  std_logic_vector(caged_pos_bitwidth-1 downto 0);-- Input address, width defined by port depth
    caged_RW_CLK  : IN  std_logic;                   -- 1-bit input clock
    caged_RST     : IN  std_logic;                 -- active high reset
    caged_DATAIN  : IN  std_logic_vector(caged_RW_WIDTH-1 downto 0) := (others=>'0');                   -- Input data port, width defined by WRITE_WIDTH parameter
    caged_WRADDR  : IN  std_logic_vector(caged_pos_bitwidth-1 downto 0);           -- Input write address, width defined by write port depth
    caged_WREN    : IN  std_logic      
  );
  end component;
   
	component Audio_Codec_Wrapper Port (
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
    sda : inout STD_LOGIC;
    sim_live : in STD_LOGIC);   --  '0' simulate audio; '1' live audio
	end component;

  constant SIM_LIVE_SWITCHNUM : integer := 3;

  signal sw_ready: std_logic;
  signal sw_last_address: std_logic;
  signal sw_trigger: std_logic;
  
  signal cw_counter_control: std_logic_vector(1 downto 0);
  signal cw_write_en: std_logic := '0';
  
  signal counter_reset : std_logic;
  signal ch1, ch2: channel_t;       
  signal is_live: std_logic;    
  signal trigger: trigger_t;
  signal num_stepper_t, num_stepper_v : signed(10 downto 0);
  signal writeCntr: unsigned (9 downto 0);
  signal position: coordinate_t;
  signal reset: std_logic;   
  signal write_address: unsigned(9 downto 0);
    
begin

    -- Determine if the current row matches the stored data from BRAM which means the channel should be active (drawn)
	-- Add code here
  ch1.active <= '1' when position.row = apply_offset('0' & ch1.from_bram(15 downto 7)); -- /2 to scale into 512 height not 1024
  ch2.active <= '1' when position.row = apply_offset('0' & ch2.from_bram(15 downto 7));

	-------------------------------------------------------------------------------
	--  Buffer a copy of the sample memory to look for positive trigger crossing
	--  "Loop back" digitized audio input to the output to confirm interface is working
	-------------------------------------------------------------------------------
--	process (clk)
--	begin
--		if (rising_edge(clk)) then
--			if reset_n = '0' then
--        ch1.to_ac <= (others => '0');
--        ch2.to_ac <= (others => '0');
--			elsif(sw_ready = '1') then
--        ch1.to_ac <= ch1.from_ac;
--        ch2.to_ac <= ch2.from_ac;
--			end if;
--		end if;
--	end process;

    -- Convert Signed sample from Codec into an unsigned value
    -- Add code here (Look at make_unsigned function)
    
    -- Send the unsigned current sample to the BRAM
    -- Add code here 
	
    -- Need logic for the FLAG register
	-- Add code here
	
    ------------------------------------------------------------------------------
	-- If a button has been pressed then increment of decrement the trigger time and Volt
	--    should this be debounced?
	--  Use a debounced numeric stepper
	------------------------------------------------------------------------------
    
    -- Add 2 numeric steppers
	
	-------------------------------------------------------------------------------
	-- Address counter for RAM
	-- What range of addresses does it need to span?  Should it start at zero or something else?
	-- How high should it count?  Will it go to its start value on reset or load?
	-------------------------------------------------------------------------------
	-- Add code here.  Use a previously built counter.
	
	-------------------------------------------------------------------------------
	-- Triggering Logic: A positive crossing of the trigger occurs when the previous value is 
	--	less than the trigger and the current value is greater than or equal to
	-- the trigger.  Set the status word to alert the FSM that it should start 
	-- recording the samples.
	-------------------------------------------------------------------------------		
	trig_detect : trigger_detector
    port map (
        clk  => clk,
        reset_n => reset_n,
        threshold => "1", -- hardcode
        ready => sw_ready,
        monitored_signal => "1", -- hardcode
        crossed_trigger => sw_trigger
    );
	
	-------------------------------------------------------------------------------
	-- Instantiate the video driver from Lab1 - should integrate smoothly
	-------------------------------------------------------------------------------
	video_inst: video port map( 
		clk =>clk,
		reset_n => reset_n,
        tmds => tmds,
		tmdsb => tmdsb,
		trigger => trigger,
		position => position,
		ch1 => ch1, 
		ch2 => ch2); 

ch1.en <= ch1.en;
ch2.en <= ch2.en;

-- Audio Codec stuff goes here

is_live <= switch(SIM_LIVE_SWITCHNUM);  --  '0' simulate audio; '1' live audio
                  -- should a switch go here?
                  

Audio_Codec : Audio_Codec_Wrapper Port map (
  clk => clk,
  reset_n => reset_n, 
  ac_mclk => ac_mclk,
  ac_adc_sdata => ac_adc_sdata,
  ac_dac_sdata => ac_dac_sdata,
  ac_bclk => ac_bclk,
  ac_lrclk => ac_lrclk,
  ready => sw_ready,
  L_bus_in  => ch1.to_ac, -- left channel input to DAC
  R_bus_in  => ch2.to_ac, -- right channel input to DAC
  L_bus_out => ch1.from_ac, -- left channel output from ADC
  R_bus_out => ch2.from_ac, -- right channel output from ADC
  scl => scl,
  sda => sda,
  sim_live => is_live);  --  '0' simulate audio; '1' live audio

    -- BRAM stuff goes here

	reset <= not reset_n;
	

leftChannelMemory : BRAM_macro_cage
  Generic map(
  caged_RW_width     => 16,
  caged_pos_bitwidth => 10)
Port map(
  caged_DATAOUT => ch1.from_bram,
  caged_RDADDR  => std_logic_vector(position.col), -- Input address, width defined by port depth
  caged_RW_CLK  => clk,                 -- 1-bit input clock
  caged_RST     => reset,                 -- active high reset
  caged_DATAIN  => ch1.to_bram,                  -- Input data port, width defined by WRITE_WIDTH parameter
  caged_WRADDR  => (others=>'0'),          -- Input write address, width defined by write port depth
  caged_WREN    =>cw_write_en    
);

		 
rightChannelMemory : BRAM_macro_cage 
  Generic map(
  caged_RW_width     => 16, 
  caged_pos_bitwidth => 10) 
Port map(
  caged_DATAOUT => ch2.from_bram,
  caged_RDADDR  => std_logic_vector(position.col), -- Input address, width defined by port depth
  caged_RW_CLK  => clk,                 -- 1-bit input clock
  caged_RST     => reset,                 -- active high reset
  caged_DATAIN  => ch2.to_bram,                  -- Input data port, width defined by WRITE_WIDTH parameter
  caged_WRADDR  => (others=>'0'),          -- Input write address, width defined by write port depth
  caged_WREN    =>cw_write_en    
);
  sw(0) <= sw_ready;
  sw(1) <= sw_last_address;
  sw(2) <= sw_trigger;
  
   
  cw_counter_control <= cw(1 downto 0);
  cw_write_en <= cw(2);
  
  ch1.en <= switch(0);
  ch2.en <= switch(1);

end lab2_datapath_arch;

