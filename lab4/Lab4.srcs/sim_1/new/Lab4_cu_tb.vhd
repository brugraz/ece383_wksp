library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lab4_cu_tb is
end Lab4_cu_tb;

architecture behavior of Lab4_cu_tb is

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal cw      : std_logic_vector(4 downto 0);
    signal sw      : std_logic_vector(0 downto 0);

    constant clk_period : time := 10 ns;

    component Lab4_cu
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            cw      : out std_logic_vector(4 downto 0);
            sw      : in std_logic_vector(0 downto 0)
        );
    end component;

    -- Expected CWs for each FSM state
    type cw_array is array(0 to 7) of std_logic_vector(4 downto 0);
    constant expected_cw : cw_array := (
        "00000",  -- wait_ready_high
        "00001",  -- inc_phase
        "00000",  -- get_base
        "00100",  -- store_base
        "00010",  -- get_next
        "01010",  -- store_next
        "10000",  -- store_result
        "00000"  -- wait_ready_low
    );

    -- Convert std_logic_vector to string for reporting
    function slv_to_str(slv: std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            result(i - slv'low + 1) := std_ulogic'image(slv(i))(2);  -- extract character from 'U'
        end loop;
        return result;
    end;

    -- Assertion procedure with report
    procedure check(actual: std_logic_vector; expected: std_logic_vector; text_label: string) is
        variable actual_str   : string(1 to actual'length);
        variable expected_str : string(1 to expected'length);
    begin
        actual_str   := slv_to_str(actual);
        expected_str := slv_to_str(expected);
        report text_label & " cw = " & actual_str;
        assert actual = expected
            report text_label & " mismatch! Expected: " & expected_str & ", Got: " & actual_str
            severity failure;
    end procedure;

begin

    -- DUT instantiation
    uut: Lab4_cu
        port map (
            clk     => clk,
            reset_n => reset_n,
            cw      => cw,
            sw      => sw
        );

    -- Clock process
    clk_process : process
    begin
        while now < 100 ns loop
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
        -- Apply reset
        reset_n <= '0';
        wait until rising_edge(clk);
        reset_n <= '1';

        -- Cycle 0: wait_ready_high
        check(cw, expected_cw(0), "Cycle 0: wait_ready_high");
        wait until rising_edge(clk);
        sw(0) <= '1';
        wait until falling_edge(clk);
        check(cw, expected_cw(0), "Cycle 0: wait_ready_high");        
        
        -- Cycle 1: inc_phase
        wait until rising_edge(clk);
        sw(0) <= '0';
        wait until falling_edge(clk);
        check(cw, expected_cw(1), "Cycle 1: inc_phase");

        -- Cycle 2: get_base
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        check(cw, expected_cw(2), "Cycle 2: get_base");
       
        -- Cycle 3: store_base
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(3), "Cycle 3: store_base");

        -- Cycle 4: get_next
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(4), "Cycle 4: get_next");        
        
        -- Cycle 5: store_next
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(5), "Cycle 5: store_next");

        -- Cycle 6: store_result
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(6), "Cycle 6: store_result");

        -- Cycle 7: wait_ready_low
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(7), "Cycle 7: wait_ready_low");

        -- Cycle 0: back to wait_ready_high
        wait until rising_edge(clk);
        wait until falling_edge(clk);        
        check(cw, expected_cw(0), "Cycle 0: wait_ready_high again");

        report "All Lab4_cu control word transitions verified successfully!";
        wait;
    end process;

end behavior;
