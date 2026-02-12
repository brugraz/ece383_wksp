----------------------------------------------------------------------------------
-- While the monitored_signal crosses the threshold, trigger is set
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trigger_detector is
    port (
        clk              : in  std_logic;
        reset_n          : in  std_logic;
        threshold        : in  unsigned;
        ready            : in  std_logic;
        monitored_signal : in  unsigned;
        crossed_trigger  : out std_logic
    );
end entity trigger_detector;

architecture trigger_detector_arch of trigger_detector is
    signal previous : unsigned(15 downto 0);
begin

    -- Register to hold previous value
    process (clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- Add code here
            --elsif 
                -- Add code here
            end if;
        end if;
    end process;

--    crossed_trigger <= -- Add code here

end architecture trigger_detector_arch;
