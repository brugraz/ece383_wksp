----------------------------------------------------------------------------------
-- Title: Lab4_cu
-- Engineer: 
-- Date:   
-- Description:  Controls the Lab4 datapath
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lab4_cu is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(4 downto 0);  -- control word
        sw      : in std_logic_vector(0 downto 0) -- status word
    );
end Lab4_cu;

architecture Lab4_cu_arch of Lab4_cu is

    type state_type is (wait_ready_high, inc_index_offset, get_base, store_base, get_next, store_next, store_result, wait_ready_low);
    signal state, next_state : state_type;

begin

    -- State register
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= wait_ready_high;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    -- Next-state logic
    next_state <= inc_index_offset when state = wait_ready_high and sw(0) = '1' else
                  wait_ready_high when state = wait_ready_high and sw(0) = '0' else
                  get_base when state = inc_index_offset else
                  store_base when state = get_base else
                  get_next when state = store_base else
                  store_next when state = get_next else
                  store_result when state = store_next else
                  wait_ready_low when state = store_result else
                  wait_ready_high when state = wait_ready_low and sw(0) = '0' else
                  wait_ready_low when state = wait_ready_low and sw(0) = '1' else
                  next_state;
    
    -- Output logic
    cw <= "00000" when state = wait_ready_high else
          "00001" when state = inc_index_offset else
          "00000" when state = get_base else
          "00100" when state = store_base else
          "00010" when state = get_next else
          "01010" when state = store_next else
          "10000" when state = store_result else
          "00000" when state = wait_ready_low else
          "00000";
          
end Lab4_cu_arch;
