library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Interpolate_tb is
end Interpolate_tb;

architecture behavior of Interpolate_tb is

    constant whole_bits : natural := 8;
    constant frac_bits  : natural := 8;
    constant data_size  : natural := 16;

    signal offset           : std_logic_vector(frac_bits - 1 downto 0);
    signal base_value       : std_logic_vector(data_size - 1 downto 0);
    signal next_value       : std_logic_vector(data_size - 1 downto 0);
    signal interpolated_out : std_logic_vector(data_size - 1 downto 0);

    component Interpolate
        generic (
            whole_bits : natural := 8;
            frac_bits  : natural := 8;
            data_size  : natural := 16
        );
        port (
            offset           : in  std_logic_vector(frac_bits - 1 downto 0);
            base_value       : in  std_logic_vector(data_size - 1 downto 0);
            next_value       : in  std_logic_vector(data_size - 1 downto 0);
            interpolated_out : out std_logic_vector(data_size - 1 downto 0)
        );
    end component;

    -- Helper for checking result
    procedure check_signed(base_val: integer; next_val: integer; expected: integer; actual_vec: std_logic_vector; msg: string) is
        variable actual : integer := to_integer(signed(actual_vec));
    begin        
        report msg & ": base = " & integer'image(base_val) & ": next = " & integer'image(next_val) & ": actual = " & integer'image(actual);
        assert actual = expected
            report msg & " mismatch: expected " & integer'image(expected)
            severity failure;
    end;

begin

    -- DUT instantiation
    uut: Interpolate
        generic map (
            whole_bits => whole_bits,
            frac_bits  => frac_bits,
            data_size  => data_size
        )
        port map (
            offset           => offset,
            base_value       => base_value,
            next_value       => next_value,
            interpolated_out => interpolated_out
        );

    -- Stimulus process
    stim_proc: process
        variable base_int, next_int : integer;
        variable expected            : integer;
    begin
        -- Case: base = -200, next = 200
        base_int := -200;
        next_int :=  200;
        base_value <= std_logic_vector(to_signed(base_int, data_size));
        next_value <= std_logic_vector(to_signed(next_int, data_size));

        -- Offset = 0.0 (Q0.8 = 0)
        offset <= std_logic_vector(to_unsigned(0, frac_bits));
        wait for 10 ns;
        expected := base_int;        
        check_signed(base_int, next_int, expected, interpolated_out, "Offset 0.0");

        -- Offset = 1.0 (Q0.8 = 255/256)
        offset <= std_logic_vector(to_unsigned(255, frac_bits));
        wait for 10 ns;
        expected := base_int + ((next_int - base_int) * 255) / 256;
        check_signed(base_int, next_int, expected, interpolated_out, "Offset ~1.0");

        -- Offset = 0.5 (Q0.8 = 128)
        offset <= std_logic_vector(to_unsigned(128, frac_bits));
        wait for 10 ns;
        expected := base_int + ((next_int - base_int) * 128) / 256;
        check_signed(base_int, next_int, expected, interpolated_out, "Offset 0.5");

        -- Offset = 0.25 (Q0.8 = 64)
        offset <= std_logic_vector(to_unsigned(64, frac_bits));
        wait for 10 ns;
        expected := base_int + ((next_int - base_int) * 64) / 256;
        check_signed(base_int, next_int, expected, interpolated_out, "Offset 0.25");

        -- Offset = 0.75 (Q0.8 = 192)
        offset <= std_logic_vector(to_unsigned(192, frac_bits));
        wait for 10 ns;
        expected := base_int + ((next_int - base_int) * 192) / 256;
        check_signed(base_int, next_int, expected, interpolated_out, "Offset 0.75");
       
        -- Case: base = 63041, next = 63339
        base_int := -2495; -- x"F641"
        next_int := -2197; -- x"F76B";
        base_value <= std_logic_vector(to_signed(base_int, data_size));
        next_value <= std_logic_vector(to_signed(next_int, data_size));

        -- Offset = 0.25 (Q0.8 = 64)
        offset <= std_logic_vector(to_unsigned(64, frac_bits));
        wait for 10 ns;
        expected := base_int + ((next_int - base_int) * 64) / 256;      
        check_signed(base_int, next_int, expected, interpolated_out, "Offset 0.25");

        report "All Q8.8 signed interpolation tests passed!";        
        
        wait;
    end process;

end behavior;
