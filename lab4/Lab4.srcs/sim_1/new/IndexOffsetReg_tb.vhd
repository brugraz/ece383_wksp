library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IndexOffsetReg_tb is
end IndexOffsetReg_tb;

architecture behavior of IndexOffsetReg_tb is

    constant whole_bits : integer := 8;
    constant frac_bits  : integer := 8;
    constant total_bits : integer := whole_bits + frac_bits;

    -- Signals
    signal clk           : std_logic := '0';
    signal reset_n       : std_logic := '0';
    signal en            : std_logic := '0';
    signal phase_inc     : std_logic_vector(total_bits - 1 downto 0) := (others => '0');
    signal index_offset  : std_logic_vector(total_bits - 1 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

    component IndexOffsetReg is
        generic (
            whole_bits : integer := 4;
            frac_bits  : integer := 4
        );
        port (
            phase_inc     : in  std_logic_vector(total_bits - 1 downto 0);
            clk           : in  std_logic;
            reset_n       : in  std_logic;
            en            : in  std_logic;
            index_offset  : out std_logic_vector(total_bits - 1 downto 0)
        );
    end component;

    -- Helper for checking result
    procedure check(expected: integer; actual_vec: std_logic_vector; msg: string) is
        variable actual : integer := to_integer(unsigned(actual_vec));
    begin
        report msg & " = " & integer'image(actual);
        assert actual = expected
            report msg & " mismatch: expected " & integer'image(expected)
            severity failure;
    end;

begin

    -- Instantiate the UUTs
    uut: IndexOffsetReg
        generic map (
            whole_bits => whole_bits,
            frac_bits  => frac_bits
        )
        port map (
            phase_inc    => phase_inc,
            clk          => clk,
            reset_n      => reset_n,
            en           => en,
            index_offset => index_offset
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
    begin
        -- Reset
        reset_n <= '0';
        en      <= '0';
        wait for clk_period;
        reset_n <= '1';

        -- Apply phase_inc and step 4 enabled cycles
        phase_inc <= x"0222";  -- +2.1333 in Q8.8
        en        <= '1';

        wait until rising_edge(clk);  -- 0+phase_inc
        wait until falling_edge(clk); 
        check(to_integer(unsigned(phase_inc)*1), index_offset, "Cycle 1");

        wait until rising_edge(clk);  -- +phase_inc
        wait until falling_edge(clk);
        check(to_integer(unsigned(phase_inc)*2), index_offset, "Cycle 2");

        wait until rising_edge(clk);  -- +phase_inc
        wait until falling_edge(clk);
        check(to_integer(unsigned(phase_inc)*3), index_offset, "Cycle 3");

        wait until rising_edge(clk);  -- +phase_inc
        wait until falling_edge(clk);
        check(to_integer(unsigned(phase_inc)*4), index_offset, "Cycle 4");

        -- Disable enable
        en <= '0';
        wait until rising_edge(clk);  -- should not increase
        wait until falling_edge(clk);
        check(to_integer(unsigned(phase_inc)*4), index_offset, "Cycle 5 (hold)");

        report "IndexOffsetReg test complete.";
        wait;
    end process;

end behavior;
