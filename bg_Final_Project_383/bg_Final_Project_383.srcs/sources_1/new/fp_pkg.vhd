----------------------------------------------------------------------------------
-- C2C Bruno Graziano, 5 May 2026
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fp_pkg is

-- row 1: 697 Hz -> 1.99168156679
constant Hz_697 : integer := 697;
-- row 2: 770 Hz -> 1.9898494165
constant Hz_770 : integer := 770;
-- row 3: 852 Hz -> 1.98757471805
constant Hz_852 : integer := 852;
-- row 4: 941 Hz -> 1.98484669624
constant Hz_941 : integer := 941;

-- col 1: 1209 Hz -> 1.97500672043
constant Hz_1209 : integer := 1209;
-- col 2: 1336 Hz -> 1.96949415673
constant Hz_1336 : integer := 1336;
-- col 3: 1477 Hz -> 1.96423028258
constant Hz_1477 : integer := 1477;
-- col 4: 1633 Hz -> 1.95448072706
constant Hz_1633 : integer := 1633;

-- coefficients 2cos(2pi*f_targ/Fs) with Fs = 48kHz, for the 8 frequencies.
constant K_Row1 : signed(15 downto 0) := x"7f77";
constant K_Row2 : signed(15 downto 0) := x"7f59";
constant K_Row3 : signed(15 downto 0) := x"7f34";
constant K_Row4 : signed(15 downto 0) := x"7f07";

constant K_Col1 : signed(15 downto 0) := x"7e66";
constant K_Col2 : signed(15 downto 0) := x"7e0c";
constant K_Col3 : signed(15 downto 0) := x"7db5";
constant K_Col4 : signed(15 downto 0) := x"7d16";

-- detection hex ID ordering, naming them.
constant hexid_697 : std_logic_vector(1 downto 0) := "00";
constant hexid_770 : std_logic_vector(1 downto 0) := "01";
constant hexid_852 : std_logic_vector(1 downto 0) := "10";
constant hexid_941 : std_logic_vector(1 downto 0) := "11";

constant hexid_1209 : std_logic_vector(1 downto 0) := "00";
constant hexid_1336 : std_logic_vector(1 downto 0) := "01";
constant hexid_1477 : std_logic_vector(1 downto 0) := "10";
constant hexid_1633 : std_logic_vector(1 downto 0) := "11";
-- combined rows & cols just to happen to give the DTMF key in hex(3:0).

-- ASCII key codes
constant UTF8_1    : std_logic_vector(7 downto 0) := x"31";
constant UTF8_2    : std_logic_vector(7 downto 0) := x"32";
constant UTF8_3    : std_logic_vector(7 downto 0) := x"33";
constant UTF8_4    : std_logic_vector(7 downto 0) := x"34";
constant UTF8_5    : std_logic_vector(7 downto 0) := x"35";
constant UTF8_6    : std_logic_vector(7 downto 0) := x"36";
constant UTF8_7    : std_logic_vector(7 downto 0) := x"37";
constant UTF8_8    : std_logic_vector(7 downto 0) := x"38";
constant UTF8_9    : std_logic_vector(7 downto 0) := x"39";
constant UTF8_0    : std_logic_vector(7 downto 0) := x"30";
constant UTF8_star : std_logic_vector(7 downto 0) := x"2A";
constant UTF8_pnd  : std_logic_vector(7 downto 0) := x"23";

constant UTF8_A    : std_logic_vector(7 downto 0) := x"41";
constant UTF8_B    : std_logic_vector(7 downto 0) := x"42";
constant UTF8_C    : std_logic_vector(7 downto 0) := x"43";
constant UTF8_D    : std_logic_vector(7 downto 0) := x"44";

-- cw and sw bits
constant CW_POWER_CALC_RST : integer := 2;
constant CW_COUNT_N : integer := 1;
constant CW_DO_S_MATH : integer := 0;

constant SW_READY : integer := 1;
constant SW_WINDOWFIN : integer := 0;

end package;

