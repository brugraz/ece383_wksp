----------------------------------------------------------------------------------
-- Title: Lab4
-- Engineer: 
-- Date:   
-- Description:  Implements an interpolated sinewave from a lookup table
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab4 is
    Port (
        clk : in  STD_LOGIC;
        reset_n : in  STD_LOGIC;
        btn : in std_logic_vector (4 downto 0);
        switch : in std_logic_vector(3 downto 0);
        ac_mclk : out STD_LOGIC;
        ac_adc_sdata : in STD_LOGIC;
        ac_dac_sdata : out STD_LOGIC;
        ac_bclk : out STD_LOGIC;
        ac_lrclk : out STD_LOGIC;
        scl : inout STD_LOGIC;
        sda : inout STD_LOGIC    
    );
end Lab4;

architecture Structural of Lab4 is

constant bup : integer := 0;
constant bleft : integer := 1;
constant bdown : integer := 2;
constant bright : integer := 3;
constant bcenter : integer := 4;

    signal cw : std_logic_vector(4 downto 0);  -- control word from CU to DP
    signal sw : std_logic_vector(0 downto 0); -- status word from DP to CU
    signal uninterpolated, interpolated, output_signal: std_logic_vector (17 downto 0);
    signal phase_inc : std_logic_vector(15 downto 0) := "0000000010110100"; -- may 28, 528 gets ph inc 0.704 -> 0.10110100 -- Example phase increment for 400Hz -- TODO: Change this so you see 1.5 cycles across your oscilloscope display

    component Lab4_cu is
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            cw      : out std_logic_vector(4 downto 0);
            sw      : in std_logic_vector(0 downto 0)
        );
    end component;

    component Lab4_dp is
        port (
            clk               : in  std_logic;
            uninterpolated_out : out std_logic_vector(17 downto 0);
            interpolated_out   : out std_logic_vector(17 downto 0);
            cw                : in  std_logic_vector(4 downto 0);
            phase_inc          : in STD_LOGIC_VECTOR (15 downto 0)                        
        );
    end component;

	component Audio_Codec_Wrapper 
    port ( clk : in STD_LOGIC;
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
	
begin

    -- Instantiate Control Unit
    CU: Lab4_cu
        port map (
            clk     => clk,
            reset_n => reset_n,
            cw      => cw,
            sw      => sw        );

    -- Instantiate Datapath
    DP: Lab4_dp
        port map (
            clk                => clk,
            uninterpolated_out => uninterpolated,
            interpolated_out   => interpolated,
            cw                 => cw,
            phase_inc          => phase_inc
        );
        
    -- Instantiate Audio Codec
        -- Audio Codec
    Audio_Codec : Audio_Codec_Wrapper
    port map ( clk => clk,
        reset_n => reset_n, 
        ac_mclk => ac_mclk,
        ac_adc_sdata => ac_adc_sdata,
        ac_dac_sdata => ac_dac_sdata,
        ac_bclk => ac_bclk,
        ac_lrclk => ac_lrclk,
        ready => sw(0),
        L_bus_in => output_signal, -- left channel input to DAC
        R_bus_in => output_signal, -- right channel input to DAC
        L_bus_out => OPEN, -- left channel output from ADC
        R_bus_out => OPEN, -- right channel output from ADC
        scl => scl,
        sda => sda,
        sim_live => '1');  --  '0' simulate audio; '1' live audio

    output_signal <= interpolated when switch(3) = '1' else uninterpolated;

    -- TODO: Replace one of the phase increments with a value which produces a frequency equal to
    --   your birth month concatenated with your birth day.  For example, if you were born on July 6th
    --   the frequency should be 0706 = 706 Hz.
    phase_inc <= x"00BD" when btn(0) = '1' else -- up
                 x"00C8" when btn(1) = '1' else -- left
                 x"00DD" when btn(2) = '1' else -- down
                 x"00EE" when btn(3) = '1' else -- right
                 x"010B" when btn(4) = '1' else -- cent
                 x"0096" when switch(0) = '1' else
                 x"00A8" when switch(1) = '1' else
                 x"00B4" when switch(2) = '1' else -- birthfreq here
                 x"012C";

end Structural;
