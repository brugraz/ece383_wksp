----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2026 01:28:16 PM
-- Design Name: 
-- Module Name: scancode_decoder - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scancode_decoder is 
 port(
 scancode      : in  std_logic_vector(7 downto 0);
 decoded_value : out std_logic_vector(3 downto 0)
 );
end scancode_decoder;

architecture Behavioral of scancode_decoder is

constant key0sc : std_logic_vector(7 downto 0) := x"45";
constant key1sc : std_logic_vector(7 downto 0) := x"16";
constant key2sc : std_logic_vector(7 downto 0) := x"1E";
constant key3sc : std_logic_vector(7 downto 0) := x"26";
constant key4sc : std_logic_vector(7 downto 0) := x"25";
constant key5sc : std_logic_vector(7 downto 0) := x"2E";
constant key6sc : std_logic_vector(7 downto 0) := x"36";
constant key7sc : std_logic_vector(7 downto 0) := x"3D";
constant key8sc : std_logic_vector(7 downto 0) := x"3E";
constant key9sc : std_logic_vector(7 downto 0) := x"46";

begin

-- add logic convert scancodes to key nums


decoded_value <= x"0" when scancode = key0sc else
                 x"1" when scancode = key1sc else
                 x"2" when scancode = key2sc else
                 x"3" when scancode = key3sc else
                 x"4" when scancode = key4sc else
                 x"5" when scancode = key5sc else
                 x"6" when scancode = key6sc else
                 x"7" when scancode = key7sc else
                 x"8" when scancode = key8sc else
                 x"9" when scancode = key9sc else
                 x"A"; -- error val

end Behavioral;
