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


entity lab2_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (2 downto 0);
           cw : out  STD_LOGIC_VECTOR (2 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is

--	type state_type is NEED_SOMETHING_HERE;
--	signal state: state_type;

begin

	-------------------------------------------------------------------------------
	--		SW		meaning
	--		
	-------------------------------------------------------------------------------
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
--			if (reset_n = '0') then 
--				state <= NEED_SOMETHING_HERE;
--			else 
--				case state is
--					when NEED_SOMETHING_HERE
--				end case;
--			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------
	--  CW output table
	--		CW		meaning
	--		
	-------------------------------------------------------------------------------
	
	-- NEED_SOMETHING_HERE

end Behavioral;

