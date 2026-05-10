library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BaseAndNextReg_tb is
end BaseAndNextReg_tb;

architecture behavior of BaseAndNextReg_tb is

    constant data_size : natural := 16;
    
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '1';
    signal data_in   : std_logic_vector(data_size - 1 downto 0) := (others => '0');
    signal base_en   : std_logic := '0';
    signal next_en   : std_logic := '0';
    signal base_out  : std_logic_vector(data_size - 1 downto 0);
    signal next_out  : std_logic_vector(data_size - 1 downto 0);

    -- DUT
    component BaseAndNextReg is
        generic (
            data_size : natural := 16
        );
        port (
            data_in   : in std_logic_vector(data_size - 1 downto 0);
            base_en   : in std_logic;
            next_en   : in std_logic;
            clk       : in std_logic;
            reset_n   : in std_logic;
            base_out  : out std_logic_vector(data_size - 1 downto 0);
            next_out  : out std_logic_vector(data_size - 1 downto 0)
        );
    end component;

begin

    DUT: BaseAndNextReg
        generic map (data_size => data_size)
        port map (
            data_in   => data_in,
            base_en   => base_en,
            next_en   => next_en,
            clk       => clk,
            reset_n   => reset_n,
            base_out  => base_out,
            next_out  => next_out
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus
    stim_proc: process
        procedure check(signal_name : string; actual, expected : std_logic_vector) is
        begin
            report "Checking " & signal_name & ": actual = " & integer'image(to_integer(signed(actual)))
                   & ", expected = " & integer'image(to_integer(signed(expected)));
            assert actual = expected
                report signal_name & " mismatch!"
                severity failure;
        end;
        
        function to_slv(val : integer) return std_logic_vector is
        begin
            return std_logic_vector(to_signed(val, data_size));
        end;

        function zeros(n : natural) return std_logic_vector is
            variable result : std_logic_vector(n - 1 downto 0);
        begin
            for i in result'range loop
                result(i) := '0';
            end loop;
            return result;
        end;

    begin
        -- Reset
        report "Test 0: Applying reset...";
        reset_n <= '0';
        wait for 10 ns;
        reset_n <= '1';
        wait for 10 ns;
        check("base_out after reset", base_out, zeros(base_out'length));
        check("next_out after reset", next_out, zeros(next_out'length));

        -- Test 1: Load base only
        report "Test 1: Load base only...";
        data_in <= to_slv(42);
        base_en <= '1';
        next_en <= '0';
        wait for 10 ns;
        base_en <= '0';
        check("base_out", base_out, to_slv(42));
        check("next_out", next_out, zeros(next_out'length));

        -- Test 2: Load next only
        report "Test 2: Load next only...";
        data_in <= to_slv(77);
        next_en <= '1';
        wait for 10 ns;
        next_en <= '0';
        check("base_out", base_out, to_slv(42));
        check("next_out", next_out, to_slv(77));

        -- Test 3: Load both simultaneously
        report "Test 3: Load both...";
        data_in <= to_slv(1234);
        base_en <= '1';
        next_en <= '1';
        wait for 10 ns;
        base_en <= '0';
        next_en <= '0';
        check("base_out", base_out, to_slv(1234));
        check("next_out", next_out, to_slv(1234));

        -- Test 4: No enable active
        report "Test 4: No enable...";
        data_in <= to_slv(9999);
        wait for 10 ns;
        check("base_out", base_out, to_slv(1234)); -- should remain unchanged
        check("next_out", next_out, to_slv(1234));

        -- Test 5: Reset again
        report "Test 5: Second reset...";
        reset_n <= '0';
        wait for 10 ns;
        reset_n <= '1';
        wait for 10 ns;
        check("base_out after 2nd reset", base_out, zeros(base_out'length));
        check("next_out after 2nd reset", next_out, zeros(next_out'length));

        report "All test cases completed successfully.";
        wait;
    end process;

end behavior;
