----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2026 01:28:16 PM
-- Design Name: 
-- Module Name: scancode_decoder_tb - Behavioral
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scancode_decoder_tb is
--  Port ( );
end scancode_decoder_tb;

architecture test_bench of scancode_decoder_tb is

-- scancodes
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

signal w_scancode      : std_logic_vector(7 downto 0);
signal w_decoded_value : std_logic_vector(3 downto 0);

constant k_keysamount : integer := 10;

subtype subt_scancode is std_logic_vector(7 downto 0);
type type_scancodes is array (1 to k_keysamount) of subt_scancode;

subtype subt_decoded is std_logic_vector(3 downto 0);
type type_decoded is array (1 to k_keysamount) of subt_decoded;

signal w_scancode_M : type_scancodes :=
(
  key0sc, key1sc, key2sc, key3sc, key4sc,
  key5sc, key6sc, key7sc, key8sc, key9sc
);

signal w_decoded_value_M : type_decoded :=
(
  x"0", x"1", x"2", x"3", x"4",
  x"5", x"6", x"7", x"8", x"9"
);

begin

uut_inst : entity work.scancode_decoder
port map (
  scancode      => w_scancode,
  decoded_value => w_decoded_value
);

test_process : process
begin
  wait for 10 ns;  -- allow DUT to settle

  for i in 1 to k_keysamount loop
    w_scancode <= w_scancode_M(i);
    wait for 10 ns;

    assert w_decoded_value = w_decoded_value_M(i)
      report "error on digit " & integer'image(i-1)
      severity failure;
  end loop;

  wait;
end process;

end test_bench;