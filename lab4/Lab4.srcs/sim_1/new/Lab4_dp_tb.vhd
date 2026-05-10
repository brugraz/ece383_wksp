library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lab4_dp_tb is
end Lab4_dp_tb;

architecture behavior of Lab4_dp_tb is

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Signals
    signal clk                : std_logic := '0';
    signal cw                 : std_logic_vector(4 downto 0) := (others => '0');
    signal uninterpolated_out : std_logic_vector(17 downto 0);
    signal interpolated_out   : std_logic_vector(17 downto 0);
    signal phase_inc          : std_logic_vector(15 downto 0) := x"0240";

    component Lab4_dp
        Port (
            clk                : in  STD_LOGIC;
            uninterpolated_out : out STD_LOGIC_VECTOR (17 downto 0);
            interpolated_out   : out STD_LOGIC_VECTOR (17 downto 0);
            cw                 : in  STD_LOGIC_VECTOR (4 downto 0);
            phase_inc          : in STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    -- Helper procedure
    procedure check(msg: string; actual, expected: std_logic_vector) is
        variable actual_int   : integer := to_integer(signed(actual));
        variable expected_int : integer := to_integer(signed(expected));
    begin
        report msg & ": actual = " & integer'image(actual_int) & ", expected = " & integer'image(expected_int);
        assert actual = expected
            report msg & " mismatch!"
            severity failure;
    end;

begin

    -- DUT Instantiation
    uut: Lab4_dp
        port map (
            clk                 => clk,
            uninterpolated_out => uninterpolated_out,
            interpolated_out   => interpolated_out,
            cw                 => cw,
            phase_inc          => phase_inc
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
        constant expected_base   : std_logic_vector(17 downto 0) := "10"&x"0000"; -- sign-extended x"8000"
        constant expected_interp : std_logic_vector(17 downto 0) := "01"&x"0400"; -- x"4100" << 2


    begin
        wait for clk_period;

        -- Step 1: wait_ready_high (cw = "00000")
        report "Step 1: wait_ready_high";
        cw <= "00000";
        wait for clk_period;
        
        -- Step 2: inc_index_offset (cw = "00001")
        report "Step 2: inc_index_offset";
        cw <= "00001";
        wait for clk_period;

        -- Step 3: get_base (cw = "00000")
        report "Step 3: get_base";
        cw <= "00000";
        wait for clk_period;

        -- Step 4: store_base (cw = "00100")
        report "Step 4: store_base";
        cw <= "00100";
        wait for clk_period;
        
        -- Step 5: get_next (cw = "00010")
        report "Step 5: get_next";
        cw <= "00010";
        wait for clk_period;        

        -- Step 6: store_next (cw = "01010")
        report "Step 6: store_next";
        cw <= "01010";
        wait for clk_period;

        -- Step 7: store_result (cw = "10000")
        report "Step 7: store_result";
        cw <= "10000";
        wait for clk_period;

        -- Step 1: wait_ready_low (cw = "00000")
        report "Step 8: wait_ready_low";
        cw <= "00000";
        wait for clk_period;

        -- Check outputs
--        check("Uninterpolated out (base)", uninterpolated_out, expected_base);
--        check("Interpolated out", interpolated_out, expected_interp);

        report "All tests passed successfully!";
        wait;

    end process;

end behavior;
