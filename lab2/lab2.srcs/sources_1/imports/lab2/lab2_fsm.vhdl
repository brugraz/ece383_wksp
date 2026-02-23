----------------------------------------------------------------------------------
-- Name:	Template by George York (modified from Jeff Falkinburg)
-- Date:	Spring 2023
-- File:    lab2_fsm.vhd
-- HW:	    Lab 2 
-- Pupr:	Lab 2 Finite State Machine for the write circuitry.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab2_fsm is Port(
  clk     : in   STD_LOGIC;
  reset_n : in   STD_LOGIC;
  sw      : in   STD_LOGIC_VECTOR (2 downto 0);
  cw      : out  STD_LOGIC_VECTOR (2 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is

constant cwOUT_WREN  : std_logic := '1';
constant cwOUT_WRDIS : std_logic := '0';
constant HOLD_CW_L10CNTR       : std_logic_vector := "00";
constant COUNT_CW_L10CNTR      : std_logic_vector := "01";
constant LOAD_CW_L10CNTR       : std_logic_vector := "10";
constant CLEAR_CW_L10CNTR      : std_logic_vector := "11";

type state_t is (wait_for_ready, wr_sampleandcount, wr_load_restart);
signal state : state_t;

begin

-------------------------------------------------------------------------------
--		SW		meaning
--	 (2)    '1' if trigger
--   (1)    '1' if last address (at 620th row) 
--   (0)    '1' if ready (new sample is here from audio codec and ready)
-------------------------------------------------------------------------------
state_proces: process(clk)  
begin
  if (rising_edge(clk)) then
    if (reset_n = '0') then 
      state <= wait_for_ready;
    else 
      case state is
      when wait_for_ready =>
        if sw(0) = '1' then state <= wr_sampleandcount; end if; -- else stay
      when wr_sampleandcount =>
        if sw(1) = '1' then state <= wr_load_restart; 
        elsif sw(0) = '0' then state <= wait_for_ready;
        end if;
      when wr_load_restart =>
        state <= wait_for_ready;      
      end case;
    end if;
  end if;
end process;

--------------------------------------
--  CW output table
--		CW		meaning
--	 (2)    write enable to the bram
--   (1)    counter control bit 1
--   (0)    counter control bit 0
--------------------------------------

-- outputs
cw <= cwOUT_WRDIS &  HOLD_CW_L10CNTR when state = wait_for_ready    else
      cwOUT_WREN  & COUNT_CW_L10CNTR when state = wr_sampleandcount else
      cwOUT_WRDIS &  LOAD_CW_L10CNTR when state = wr_load_restart; -- originally made this wren but doesnt seem needed

end Behavioral;

