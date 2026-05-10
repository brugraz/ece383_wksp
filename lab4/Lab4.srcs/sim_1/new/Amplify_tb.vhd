library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Amplify_tb is
end Amplify_tb;

architecture test of Amplify_tb is
    constant data_size : natural := 16;

    signal data_in  : STD_LOGIC_VECTOR(data_size - 1 downto 0);
    signal data_out : STD_LOGIC_VECTOR(data_size - 1 downto 0);
    signal scale_by : STD_LOGIC_VECTOR(2 downto 0);

    component Amplify is
        generic (
            data_size : natural := 16
        );
        port (
            data_in  : in STD_LOGIC_VECTOR(data_size - 1 downto 0);
            data_out : out STD_LOGIC_VECTOR(data_size - 1 downto 0);
            scale_by : in STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

begin

    DUT: Amplify
        generic map (data_size => data_size)
        port map (
            data_in  => data_in,
            data_out => data_out,
            scale_by => scale_by
        );

    stimulus: process
        function to_slv(val : integer; size : natural) return std_logic_vector is
        begin
            return std_logic_vector(to_signed(val, size));
        end;

        function slv_to_int(slv : std_logic_vector) return integer is
        begin
            return to_integer(signed(slv));
        end;

        procedure run_case(signal_value : integer; scale : integer; expected : integer; case_num : integer) is
        begin
            data_in  <= to_slv(signal_value, data_size);
            scale_by <= std_logic_vector(to_signed(scale, 3));

            wait for 10 ns;

            report "Case " & integer'image(case_num) & ": "
                 & integer'image(signal_value) & " * "
                 & integer'image(scale) & " = "
                 & integer'image(slv_to_int(data_out));

            assert slv_to_int(data_out) = expected
                report "FAILED case " & integer'image(case_num) & ": Expected " & integer'image(expected)
                severity failure;
        end;
    begin
        -- Run test cases
        run_case( 1000,  1,  1000, 1);  -- pos * pos
        run_case( 1000, -1, -1000, 2);  -- pos * neg
        run_case(-1000,  1, -1000, 3);  -- neg * pos
        run_case(-1000, -1,  1000, 4);  -- neg * neg
        run_case(10000,  2,  20000, 5); -- large pos * pos
        run_case(-10000, 2, -20000, 6); -- large neg * pos
        run_case(10000, -2, -20000, 7); -- large pos * neg
        run_case(32767,  2, to_integer(to_signed(32767 * 2, data_size)), 8); -- overflow

        report "All tests completed.";
        wait;
    end process;

end test;
