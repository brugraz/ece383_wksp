library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Lab4_tb is
end Lab4_tb;

architecture behavior of Lab4_tb is

    constant clk_period : time := 10 ns;

    signal clk                 : std_logic := '0';
    signal reset_n            : std_logic := '0';
    signal uninterpolated_out : std_logic_vector(17 downto 0);
    signal interpolated_out   : std_logic_vector(17 downto 0);
    signal cw                 : std_logic_vector(4 downto 0);
    signal sw                 : std_logic_vector(0 downto 0);

    -- For writing to CSV
    file output_file : text open write_mode is "lab4_output.csv";

    component Lab4_cu
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            cw      : out std_logic_vector(4 downto 0);
            sw      : in  std_logic_vector(0 downto 0)
        );
    end component;

    component Lab4_dp
        port (
            clk                 : in  std_logic;
            uninterpolated_out : out std_logic_vector(17 downto 0);
            interpolated_out   : out std_logic_vector(17 downto 0);
            cw                 : in  std_logic_vector(4 downto 0)
        );
    end component;

begin

    -- Instantiate the Control Unit
    cu_inst : Lab4_cu
        port map (
            clk     => clk,
            reset_n => reset_n,
            cw      => cw,
            sw      => sw
        );

    -- Instantiate the Datapath
    dp_inst : Lab4_dp
        port map (
            clk                 => clk,
            cw                  => cw,
            uninterpolated_out => uninterpolated_out,
            interpolated_out   => interpolated_out
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 5000 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus and output capture
    stimulus_proc : process
        variable line_out : line;
        variable result_count : integer := 0;
    begin
        -- Write CSV header
        write(line_out, string'("cycle,uninterpolated_out,interpolated_out"));
        writeline(output_file, line_out);

        -- Reset
        reset_n <= '0';
        wait for 3 * clk_period;
        reset_n <= '1';

        -- Status signal sw(0) = 1 during store_result state
        loop
            wait until rising_edge(clk);

            if cw = "10000" then  -- store_result phase
                sw(0) <= '1';
            else
                sw(0) <= '0';
            end if;

            if sw(0) = '1' then
                write(line_out, integer'image(result_count) & ",");
                write(line_out, integer'image(to_integer(signed(uninterpolated_out))) & ",");
                write(line_out, integer'image(to_integer(signed(interpolated_out))));
                writeline(output_file, line_out);

                result_count := result_count + 1;
                if result_count = 256 then
                    exit;
                end if;
            end if;
        end loop;

        report "Simulation complete. Results written to lab4_output.csv" severity note;
        wait;
    end process;

end behavior;
