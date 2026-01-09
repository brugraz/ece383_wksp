-- by chatGPT
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_tb is
end entity;

architecture tb of encoder_tb is

    signal in_value  : std_logic_vector(3 downto 0);
    signal out_value : std_logic_vector(1 downto 0);

begin

    dut: entity work.encoder
        port map (
            in_value  => in_value,
            out_value => out_value
        );

    stim_proc: process
        variable expected : std_logic_vector(1 downto 0);
    begin
        for i in 0 to 15 loop
            in_value <= std_logic_vector(to_unsigned(i, 4));
            wait for 10 ns;

            if    i >= 8 then expected := "11";
            elsif i >= 4 then expected := "10";
            elsif i >= 2 then expected := "01";
            else               expected := "00";
            end if;

            assert out_value = expected
                severity error;
        end loop;

        wait;
    end process;

end architecture;