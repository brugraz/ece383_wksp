library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LookupTable_tb is
end LookupTable_tb;

architecture behavior of LookupTable_tb is

    constant whole_bits : integer := 8;
    constant frac_bits  : integer := 8;
    constant data_bits  : integer := 16;

    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal index     : std_logic_vector(whole_bits - 1 downto 0) := (others => '0');
    signal cw        : std_logic := '0';
    signal data_out  : std_logic_vector(data_bits - 1 downto 0);

    component LookupTable is
        generic (
            whole_bits : integer := 4;
            frac_bits  : integer := 4);
        port (
            index     : in  std_logic_vector (whole_bits - 1 downto 0);
            cw        : in  std_logic;
            data_out  : out std_logic_vector (15 downto 0);
            clk       : in  std_logic;
            reset_n   : in  std_logic);
    end component;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: LookupTable
        generic map (
            whole_bits => whole_bits,
            frac_bits  => frac_bits
        )
        port map (
            index     => index,
            cw        => cw,
            data_out  => data_out,
            clk       => clk,
            reset_n   => reset_n
        );

    -- Clock generation
    clk_process: process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
        -- TODO: Update the expected values with the first 2 values from your LUT
        constant expected_base : std_logic_vector(data_bits - 1 downto 0) := x"8000";
        constant expected_next : std_logic_vector(data_bits - 1 downto 0) := x"8100";
        
        procedure check(msg: string; actual, expected: std_logic_vector) is
            variable actual_int   : integer;
            variable expected_int : integer;
        begin
            actual_int   := to_integer(unsigned(actual));  -- or signed(...) if values are signed
            expected_int := to_integer(unsigned(expected));
            
            report msg & ": actual = " & integer'image(actual_int)
                        & ", expected = " & integer'image(expected_int);
            assert actual = expected
                report msg & " mismatch!"
                severity failure;
        end;

    begin
        -- Apply reset
        report "Applying reset";
        reset_n <= '0';
        wait until rising_edge(clk);
        reset_n <= '1';
        wait until rising_edge(clk);

        -- Test 1: Read base (index = 0, cw = 0)
        report "Test 1: Read base value from index 0";
        index <= (others => '0');
        cw    <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        check("Base read at index=0", data_out, expected_base);

        -- Test 2: Read next (index = 0, cw = 1)
        report "Test 2: Read next value from index 1";
        index <= (others => '0');
        cw    <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        check("Next read at index=0+1", data_out, expected_next);

        report "All tests passed.";
        wait;
    end process;

end behavior;
