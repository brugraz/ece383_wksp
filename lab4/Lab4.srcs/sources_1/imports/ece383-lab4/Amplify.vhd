----------------------------------------------------------------------------------
-- Title: Amplify
-- Engineer: 
-- Date:   
-- Description: Amplifies the incoming signal by the scale_by amount using signed multiplication.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Amplify is
    generic (
        data_size : natural := 16);
    port ( data_in : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (data_size-1 downto 0);
           scale_by : in STD_LOGIC_VECTOR (2 downto 0)); -- Gives a range of -4 to 3 in 2's complement
end Amplify;

architecture Amplify_arch of Amplify is
    signal data_in_int  : integer;
    signal scale_by_int : integer;
    signal product_int  : integer;
begin

    -- Convert inputs to integers
    data_in_int  <= to_integer(signed(data_in));
    scale_by_int <= to_integer(signed(scale_by));

    -- Multiply
    product_int  <= data_in_int * scale_by_int;

    -- Convert back to std_logic_vector with truncation if needed
    data_out <= std_logic_vector(to_signed(product_int, data_size));
end Amplify_arch;
