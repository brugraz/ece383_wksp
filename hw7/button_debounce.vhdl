--------------------------------------------------------------------
-- Name:	George York
-- Date:	Feb 2, 2021
-- File:	button_debounce.vhdl
-- HW:	    Template for HW7
--	Crs:	ECE 383
--
-- Purp:	For this debouncer, we assume the clock is slowed from 100MHz to 100KHz,
--          and the ringing time is less than 20ms
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;		
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;

entity button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
end button_debounce;

architecture behavior of button_debounce is
	
	signal cw: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
	signal sw: STD_LOGIC:= '0';
	type state_type is (Init0, waitforpress, pressin_delay, waitforrel, act, pressout_delay);
	signal state: state_type;

  constant N_BITS : integer := 11;
  constant COOLDOWN_20ms_100k : integer := 2000;
	
	COMPONENT lec10    -- clock for 20 msec debounce delay
		generic (N: integer := 4);
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				crtl: in std_logic_vector(1 downto 0);
				D: in unsigned (N-1 downto 0);
				Q: out unsigned (N-1 downto 0));
    END COMPONENT;
	
	-- these values are for 100KHz
    signal D : unsigned(N_BITS-1 downto 0) := (others => '0'); -- set to D upon action
    signal Q : unsigned(N_BITS-1 downto 0);
        
begin
    ----------------------------------------------------------------------
	--   DATAPATH
	----------------------------------------------------------------------
	delay_counter: lec10 
    Generic map(N_BITS) 
	PORT MAP (
          clk => clk,
          reset => reset,
		  crtl => cw,
          D => D,
          Q => Q
        );	
	
	-- reminder: counter counter every other clock cycle!
   	-- these values are for 100KHz clock
    sw <= '1' when Q = COOLDOWN_20ms_100k-1 else '0';
    
   -----------------------------------------------------------------------
   --    CONTROL UNIT
   -----------------------------------------------------------------------
   state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '0') then 
				state <= Init0;
			else
				case state is
					when Init0 =>
						state <= waitforpress;
					when waitforpress =>
						if button = '1' then state <= pressin_delay; end if; -- else stay
					when pressin_delay =>
            if sw = '1' then state <= waitforrel; end if; -- else stay here at pressin
          when waitforrel =>
            if button = '0' then state <= pressout_delay; end if; -- stay if pressed
          when pressout_delay =>
            if sw = '1' then state <= act; end if;
          when act =>
            state <= waitforpress;
				end case;
			end if;
		end if;
	end process;


	------------------------------------------------------------------------------
	--			OUTPUT EQUATIONS
	--	
	--		cw is counter control:  00 is hold; 01 is increment; 11 is reset	
	------------------------------------------------------------------------------	
	cw <= "00" when state = Init0 else
        "10" when state = waitforpress else
        "01" when state = pressin_delay else
        "10" when state = waitforrel else -- reset state, could have done hold also
        "01" when state = pressout_delay else
        "10" when state = act;
	action <= '1' when state = act else '0';
	
end behavior;
