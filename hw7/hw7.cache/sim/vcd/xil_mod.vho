component button_debounce 
port(  
 clk : in std_logic;
 reset : in std_logic;
 button : in std_logic;
 action : out std_logic
);
end component; 

DUT : button_debounce
port map (
 clk=>clk,
 reset=>reset,
 button=>button,
 action=>action
);
