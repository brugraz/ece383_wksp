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
use work.ece383_pkg.all;

entity lab2_fsm is Port(
  clk     : in   STD_LOGIC;
  reset_n : in   STD_LOGIC;
  sw      : in   STD_LOGIC_VECTOR (L2SW_WIDTH-1 downto 0);
  cw      : out  STD_LOGIC_VECTOR (L2CW_WIDTH-1 downto 0);
  writeCntr_dbg : in unsigned(RDWRADDR_WIDTH-1 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is

constant cwOUT_WREN  : std_logic := '1';
constant cwOUT_WRDIS : std_logic := '0';
constant HOLD_CW_L10CNTR       : std_logic_vector := "00";
constant COUNT_CW_L10CNTR      : std_logic_vector := "01";
constant LOAD_CW_L10CNTR       : std_logic_vector := "10";
constant CLEAR_CW_L10CNTR      : std_logic_vector := "11";

type state_t is (load_wait_for_trigger, wait_for_ready, wr_sampleandcount);
signal state : state_t;
signal w_cw  : std_logic_vector(L2CW_WIDTH-1 downto 0); -- for concurrent cw output logic analysis debug

-- for live ILA debug only
--signal cw_fordbg : std_logic_vector(2 downto 0); -- control_word_type?
attribute mark_debug : string;
attribute keep       : string;

signal state_dbg : std_logic_vector(2 downto 0);
attribute mark_debug of state_dbg : signal is "true";
attribute keep       of state_dbg : signal is "true";

signal sw_dbg : std_logic_vector(2 downto 0);
attribute mark_debug of sw_dbg : signal is "true";
attribute keep       of sw_dbg : signal is "true";

signal cw_dbg : std_logic_vector(2 downto 0);
attribute mark_debug of cw_dbg : signal is "true";
attribute keep       of cw_dbg : signal is "true";

--signal w_writeCntr_dbg : unsigned(RDWRADDR_WIDTH-1 downto 0);
attribute mark_debug of writeCntr_dbg : signal is "true";
attribute keep       of writeCntr_dbg : signal is "true";
--*************************--

begin
-------------------------------------------------------------------------------
--		SW		meaning
--	 (2)    '1' if trigger
--   (1)    '1' if last address (at 620th row) 
--   (0)    '1' if ready (new sample is here from audio codec and ready)
-------------------------------------------------------------------------------

-- for live ILA debug only --
state_dbg <= std_logic_vector(to_unsigned(state_t'pos(state), state_dbg'length));
sw_dbg <= sw;
cw_dbg <= w_cw;
--update_cw_dbg : process(clk)
--begin
--if rising_edge(clk) then
--  cw_dbg <= cw use control_word_type thing
--end if;
--enf process;
--*************************--

state_proces: process(clk)  
begin
if (rising_edge(clk)) then
  if (reset_n = '0') then 
    state <= load_wait_for_trigger;
  else 
    case state is
    when load_wait_for_trigger =>
      if sw(bit_SW_TRIG) = '1' then state <= wait_for_ready; end if; -- else stay
    when wait_for_ready =>
      if sw(bit_SW_READY) = '1' then state <= wr_sampleandcount; end if; -- else stay
    when wr_sampleandcount =>
      if sw(bit_SW_LASTADDR) = '1' then state <= load_wait_for_trigger; 
      else state <= wait_for_ready; -- check this if fsm doesnt work 2.23,14:19
      end if;
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
w_cw <= cwOUT_WRDIS &  LOAD_CW_L10CNTR when state = load_wait_for_trigger  else
        cwOUT_WRDIS &  HOLD_CW_L10CNTR when state = wait_for_ready    else
        cwOUT_WREN  & COUNT_CW_L10CNTR when state = wr_sampleandcount;
cw <= w_cw;

--w_writeCntr_dbg <= writecntr_dbg;

end Behavioral;

