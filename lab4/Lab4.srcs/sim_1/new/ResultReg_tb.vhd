library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ResultReg_tb is
end ResultReg_tb;

architecture behavior of ResultReg_tb is

    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal en        : std_logic := '0';
    signal data_in   : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out  : std_logic_vector(17 downto 0);

    constant clk_period : time := 10 ns;

    component ResultReg
        port (
            data_in   : in  std_logic_vector(15 downto 0);
            data_out  : out std_logic_vector(17 downto 0);
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            en        : in  std_logic
        );
    end component;

    procedure check(actual, expected: std_logic_vector; msg: string) is
    begin
        report msg & ": actual = " & integer'image(to_integer(unsigned(actual)));
        assert actual = expected
            report msg & " mismatch! Expected: " & integer'image(to_integer(unsigned(expected)))
            severity failure;
    end procedure;

begin

    -- Instantiate DUT
    uut: ResultReg
        port map (
            data_in   => data_in,
            data_out  => data_out,
            clk       => clk,
            reset_n   => reset_n,
            en        => en
        );

    -- Clock process
    clk_process : process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc : process
        variable expected : std_logic_vector(17 downto 0);
    begin
        -- Test 1: Apply reset
        report "Test 1: Reset";
        reset_n <= '0';
        en <= '1';
        data_in <= x"AAAA";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        check(data_out, x"0000"&"00", "After reset");

        -- Test 2: Load value when en = '1'
        report "Test 2: Load value";
        reset_n <= '1';
        data_in <= x"1234";
        en <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        expected := x"1234" & "00";
        check(data_out, expected, "Load x1234 << 2");

        -- Test 3: Hold value when en = '0'
        report "Test 3: Hold previous value";
        data_in <= x"FFFF";
        en <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        check(data_out, expected, "Should hold previous value");

        -- Test 4: Load new value with en = '1'
        report "Test 4: Load new value";
        data_in <= x"00FF";
        en <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        expected := x"00FF" & "00";
        check(data_out, expected, "Load x00FF << 2");

        report "All ResultReg tests passed!";
        wait;
    end process;

end behavior;
