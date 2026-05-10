----------------------------------------------------------------------------------
-- Title: Lab4_dp
-- Engineer: 
-- Date:   
-- Description: Contains the datapath for generating a signal from a lookup table.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lab4_dp is
    Port (
        clk                 : in  STD_LOGIC;
        uninterpolated_out : out STD_LOGIC_VECTOR (17 downto 0);
        interpolated_out   : out STD_LOGIC_VECTOR (17 downto 0);
        cw                 : in  STD_LOGIC_VECTOR (4 downto 0);
        phase_inc          : in STD_LOGIC_VECTOR (15 downto 0)
    );
end Lab4_dp;

architecture Lab4_dp_arch of Lab4_dp is

    constant Q_whole    : integer := 8;
    constant Q_frac     : integer := 8;
    constant data_bits  : integer := 16;

    -- Signals
    signal index    : std_logic_vector(Q_whole - 1 downto 0);  -- 8 bits: integer part
    signal index_offset      : std_logic_vector(Q_whole + Q_frac - 1 downto 0);  -- 16-bit Q8.8

    signal lut_data         : std_logic_vector(15 downto 0);
    signal base_val         : std_logic_vector(15 downto 0);
    signal next_val         : std_logic_vector(15 downto 0);
    signal interp_val       : std_logic_vector(15 downto 0);
    signal amplified_val    : std_logic_vector(15 downto 0);
    signal result_val_shift : std_logic_vector(17 downto 0);  -- Final output

    -- Control signal aliases
    alias en_index_offset : std_logic is cw(0);
    alias lut_cw          : std_logic is cw(1);
    alias base_en         : std_logic is cw(2);
    alias next_en         : std_logic is cw(3);
    alias result_en       : std_logic is cw(4);

    -- Component Declarations
    component IndexOffsetReg
        generic (
            whole_bits : integer := 8;
            frac_bits  : integer := 8
        );
        port (
            phase_inc    : in  std_logic_vector(15 downto 0);
            clk          : in  std_logic;
            reset_n      : in  std_logic := '1';
            en           : in  std_logic;
            index_offset : out std_logic_vector(15 downto 0)
        );
    end component;

    component LookupTable
        generic (
            whole_bits : integer := 8;
            frac_bits  : integer := 8
        );
        port (
            index     : in  std_logic_vector(7 downto 0);
            cw        : in  std_logic;
            data_out  : out std_logic_vector(15 downto 0);
            clk       : in  std_logic;
            reset_n   : in  std_logic := '1'
        );
    end component;

    component BaseAndNextReg
        generic (
            data_size : integer := 16
        );
        port (
            data_in   : in  std_logic_vector(15 downto 0);
            base_en   : in  std_logic;
            next_en   : in  std_logic;
            clk       : in  std_logic;
            reset_n   : in  std_logic := '1';
            base_out  : out std_logic_vector(15 downto 0);
            next_out  : out std_logic_vector(15 downto 0)
        );
    end component;

    component Interpolate
        generic (
            whole_bits : natural := 4;
            frac_bits : natural := 4;
            data_size : natural := 16);
    port ( offset : in STD_LOGIC_VECTOR (frac_bits-1 downto 0);
           base_value : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           next_value : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           interpolated_out : out STD_LOGIC_VECTOR (data_size-1 downto 0));
    end component;

    component Amplify
        generic (
            data_size : integer := 16
        );
        port (
            data_in  : in  std_logic_vector(15 downto 0);
            data_out : out std_logic_vector(15 downto 0);
            scale_by : in  std_logic_vector(2 downto 0)
        );
    end component;

    component ResultReg
        port (
            data_in  : in  std_logic_vector(15 downto 0);
            data_out : out std_logic_vector(17 downto 0);
            clk      : in  std_logic;
            reset_n  : in  std_logic := '1';
            en       : in  std_logic);
    end component;

begin

    -- IndexOffsetReg
    IndexOffsetReg_inst : IndexOffsetReg
        generic map (
            whole_bits => Q_whole,
            frac_bits  => Q_frac
        )
        port map (
            phase_inc    => phase_inc,
            clk          => clk,
            en           => en_index_offset,
            index_offset => index_offset
        );

    -- LookupTable (integer part of Q8.8)
    LookupTable_inst : LookupTable
        generic map (
            whole_bits => Q_whole,
            frac_bits  => Q_frac
        )
        port map (
            index     => index_offset(15 downto 8),
            cw        => lut_cw,
            data_out  => lut_data,
            clk       => clk
        );

    -- BaseAndNextReg
    BaseAndNextReg_inst : BaseAndNextReg
        generic map (
            data_size => data_bits
        )
        port map (
            data_in   => lut_data,
            base_en   => base_en,
            next_en   => next_en,
            clk       => clk,
            base_out  => base_val,
            next_out  => next_val
        );

    -- Interpolate
    Interpolate_inst : Interpolate
        generic map (
        whole_bits => 8,
        frac_bits => 8,
        data_size => 16)
        port map (
            offset => index_offset(7 downto 0),
            base_value => base_val,
            next_value => next_val,
            interpolated_out  => interp_val
        );

    -- Amplify
    Amplify_inst : Amplify
        generic map (
            data_size => data_bits
        )
        port map (
            data_in  => interp_val,
            data_out => amplified_val,
            scale_by => "001"  -- example gain
        );

    -- ResultReg (now shifts data left by 2 bits)
    ResultReg_inst : ResultReg
        port map (
            data_in  => amplified_val,
            data_out => result_val_shift,
            clk      => clk,
            en       => result_en
        );

    -- Outputs
    uninterpolated_out <= base_val & "00";
    interpolated_out   <= result_val_shift;
    
    

end Lab4_dp_arch;
