----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2026 03:00:15 PM
-- Design Name: 
-- Module Name: goertzel - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library work;
use work.fp_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity goertzel is generic (f_target  : integer);
Port ( 
  clk       : in std_logic;
  reset_n   : in std_logic;
  x_b16         : in  signed (15 downto 0);
  cw   :  in std_logic_vector(2 downto 0);
  power_out_b64 : out signed (63 downto 0));
end goertzel;

architecture Behavioral of goertzel is

  signal Fs        : integer := 48000;
  signal ac_bits   : integer := 16;
  
  -- For Fs = 48kHz, the 8 DTMF frequencies: 
  -- 697, 770, 852, 941, 1209, 1336, 1477, 1633
  -- "K" (or coefficent), Q1.15 = 2*cos(omega), with omega = 2*pi*f_target/Fs
  -- K values are < 2, only vary with target frequency, and were pre-calculated.
  -- their values seen in fp_pkg
  
  -- K: 16 bit Q2.14
  -- x[n]: 16 bit signed Q 1.15 (normalized signed, -1 < x < 1)
  -- state variable s[n]: 32 bit Q16.16 since with normalized x[n] can get to ~6500
  
  -- then s[n] = K * x[n] = Q3.29 ... we want Q16.16 so shift the Q3.29 right by 13 -> Q16.16 (lost 13 LSBs and we don't care)
  
  signal K_Q0214 : signed(15 downto 0);
  signal x_Q0115 : signed(15 downto 0);
  
  signal x_Q1616 : signed(31 downto 0);
  signal s_Q1616 : signed(31 downto 0);
  signal sprev_Q1616   : signed(31 downto 0);
  signal sprev2_Q1616  : signed(31 downto 0);
  
  -- intermediate s calc signals for K*s ...
  signal K_sprev_raw_Q1830 : signed(47 downto 0);
  signal K_sprev_Q1616     : signed(31 downto 0);
  
  signal p_out_Q3232    : signed(63 downto 0);
  
begin

with f_target select
K_Q0214 <= K_Row1 when Hz_697,
           K_Row2 when Hz_770,
           K_Row3 when Hz_852,
           K_Row4 when Hz_941,
           K_Col1 when Hz_1209,
           K_Col2 when Hz_1336,
           K_Col3 when Hz_1477,
           K_Col4 when Hz_1633,
           (others => '0') when others;

-- register process for s[n], s[n-1] and s[n-2]
-- concurrent truncations, shifts, multiplies
K_sprev_raw_Q1830 <= sprev_Q1616*K_Q0214;
K_sprev_Q1616 <= resize(shift_right(K_sprev_raw_Q1830, 14), 32);
x_Q1616 <= shift_left(resize(x_Q0115, 32), 1);   -- resize first to keep MSB sign bit

process(clk)
begin
if (rising_edge(clk)) then
  if cw(CW_DO_S_MATH) = '1' then
  
    -- state s[n] = x[n] + coef*s[n-1] - s[n-2]
    s_Q1616 <= x_Q1616 + K_sprev_Q1616 - sprev2_Q1616; 
    sprev2_Q1616 <= sprev_Q1616; -- turn s[n-2] into s[n-1]
    sprev_Q1616 <= s_Q1616;       -- turn s[n-1] into s[n]
      
  elsif cw(CW_POWER_CALC_RST) = '1' then  -- window over, compute power
    
    -- power P = s[n-1]^2 + s[n-2]^2 - Ks[n-1]s[n-2]  (rearranged Re^2 + Im^2)
    p_out_Q3232 <= sprev_Q1616*sprev_Q1616 - K_sprev_Q1616*sprev2_Q1616;
    
    if reset_n = '0' then
      s_Q1616 <= (others => '0');
      sprev_Q1616 <= (others => '0');
      sprev2_Q1616 <= (others => '0');
    end if;
  end if;
  
end if;
end process;

end Behavioral;
