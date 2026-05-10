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
  -- "K" (or coefficent), Q16.16 = 2*cos(omega), with omega = 2*pi*f_target/Fs
  -- K values only vary with target frequency, and were pre-calculated.
  -- their values seen in fp_pkg
  signal K_Q0230 : signed(REG_LEN-1 downto 0);
  signal x_Q1616 : signed(31 downto 0);
  
  
  signal mulres_s_Q6630 : signed(95 downto 0);
  
  signal s_Q3232       : signed(63 downto 0);
  signal s_prev_Q3232  : signed(63 downto 0) := (others => '0');
  signal s_prev2_Q3232 : signed(63 downto 0) := (others => '0');
  signal s_Q3200       : signed(31 downto 0);
  signal s_prev_Q3200  : signed(31 downto 0) := (others => '0');
  signal s_prev2_Q3200 : signed(31 downto 0) := (others => '0');
  
  signal addmulres_p_Q6400 : signed(63 downto 0); -- was 6500
  signal addmulres_p_Q6630 : signed(95 downto 0);
  signal p_out_Q6630    : signed(95 downto 0);
  
begin

x_Q1616 <= x_b16 & x"0000"; -- add 16 bin fixed pts

with f_target select
K_Q0230 <= K_Row1 when Hz_697,
           K_Row2 when Hz_770,
           K_Row3 when Hz_852,
           K_Row4 when Hz_941,
           K_Col1 when Hz_1209,
           K_Col2 when Hz_1336,
           K_Col3 when Hz_1477,
           K_Col4 when Hz_1633,
           (others => '0') when others;

-- register process for s[n], s[n-1] and s[n-2]
-- concurrent truncations, shifts, multiply preps
    mulres_s_Q6630 <= (K_Q0230*s_prev_Q3232);
    s_Q3200 <= s_Q3232(63 downto 32);
-- truncate these things for a less onerous power calc
    s_prev_Q3200 <= s_prev_Q3232(63 downto 32);
    s_prev2_Q3200 <= s_prev2_Q3232(63 downto 32);
-- power calc prep
    addmulres_p_Q6400 <= s_prev_Q3200*s_prev_Q3200 + s_prev2_Q3200*s_prev2_Q3200;
    addmulres_p_Q6630 <= addmulres_p_Q6400 & x"00000000";

process(clk)
begin
if (rising_edge(clk)) then
  if reset_n = '0' then
    s_Q3232 <= (others => '0');
    -- add others reset prev prev2
  elsif cw(CW_DO_S_MATH) = '1' then
  
    -- s[n] = x[n] + coef*s[n-1] - s[n-2]
    s_Q3232 <= x_Q1616 + mulres_s_Q6630(63 downto 0) - s_prev2_Q3232; 
    s_prev2_Q3232 <= s_prev_Q3232; -- turn s[n-2] into s[n-1]
    s_prev_Q3232 <= s_Q3232;       -- turn s[n-1] into s[n]
      
  elsif cw(CW_POWER_CALC_RST) = '1' then  -- window over, compute power
    
    -- P = s[n-1]^2 + s[n-2]^2 - s[n-1]s[n-2]coeff  (rearranged Re^2 + Im^2)
    -- power calc
    p_out_Q6630 <= addmulres_p_Q6630 - s_prev_Q3200*s_prev2_Q3200*K_Q0230;
    
  end if;
end if;
end process;

-- out
power_out_b64 <= p_out_Q6630(95 downto 32);

end Behavioral;
