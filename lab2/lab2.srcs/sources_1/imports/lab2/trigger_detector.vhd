----------------------------------------------------------------------------------
-- While the monitored_signal crosses the threshold, trigger is set
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.all;

entity trigger_detector is Port (
  clk              : in  std_logic;
  reset_n          : in  std_logic;
  threshold        : in  unsigned; --(RDWRADDR_WIDTH-1 downto 0);
  ready            : in  std_logic;
  monitored_signal : in  unsigned(RDWRADDR_WIDTH-1 downto 0);
  crossed_trigger  : out std_logic
);
end entity trigger_detector;

architecture trigger_detector_arch of trigger_detector is

signal previous : unsigned(RDWRADDR_WIDTH-1 downto 0);

begin

  -- Register to hold previous value
process (clk)
begin
if rising_edge(clk) then
  if reset_n = '0' then previous <= (others=>'0');
  else 
  previous <= monitored_signal;
--  if monitored_signal <  threshold and previous >= threshold then 
--    crossed_trigger <= '1';
--  else
--    crossed_trigger <= '0';
--  end if;
  end if;
end if;
end process;

-- crossed_trigger <= '1' when monitored_signal <  threshold and previous >= threshold and ready = '1' else '0';
crossed_trigger <= '1' when monitored_signal <  threshold and previous >= threshold and ready = '1' else '0';

end architecture trigger_detector_arch;