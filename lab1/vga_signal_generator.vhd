-- vga_signal_generator Generates the hsync, vsync, blank, and row, col for the VGA signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity vga_signal_generator is
Port ( clk : in STD_LOGIC;
       reset_n : in STD_LOGIC;
       position: out coordinate_t;
       vga : out vga_t);
end vga_signal_generator;

architecture vga_signal_generator_arch of vga_signal_generator is

  signal horizontal_roll, vertical_roll: std_logic := '0';		
  signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
  signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
  signal current_pos : coordinate_t;
    
  constant h_max_px_total  : integer := 800;
  constant v_max_px_total  : integer := 525;
  constant px_num_bits     : integer := 10;

  constant h_max_px_visual : integer := 640;
  constant v_max_px_visual : integer := 480;

  constant h_front_porch_pxw : integer := 16;
  constant h_sync_pxw        : integer := 96;
  constant h_back_porch_pxw  : integer := 48;

  constant v_front_porch_pxw : integer := 10;
  constant v_sync_pxw        : integer := 2;
  constant v_back_porch_pxw  : integer := 33;
  -- component counter was declared in ece383_pkg that is used .ALL
    
begin
-- horizontal counter
h_counter : counter
generic map(
  num_bits  => px_num_bits,
  max_value => h_max_px_total-1
)
port map(
  clk     => clk,
  ctrl    => h_counter_ctrl,
  reset_n => reset_n,
  roll    => horizontal_roll,
  Q       => current_pos.col
);
    
-- Glue code to connect the horizontal and vertical counters
v_counter_ctrl <= horizontal_roll;

-- vertical counter
  v_counter : counter
  generic map(
    num_bits  => px_num_bits,
    max_value => v_max_px_total-1
  )
  port map(
    clk     => clk,
    ctrl    => v_counter_ctrl,
    reset_n => reset_n,
    roll    => vertical_roll,
    Q       => current_pos.row
  );
  
-- Assign VGA outputs in a gated manner

process (clk)
begin
  if (rising_edge(clk)) then
    if (current_pos.col >= (h_max_px_visual-1) and not (current_pos.col = h_max_px_total-1)) then
      h_blank_is_low <= false; else h_blank_is_low <= true; end if;
    if (current_pos.row >= (v_max_px_visual-1) and not (current_pos.row = v_max_px_total-1)) then
      v_blank_is_low <= false; else v_blank_is_low <= true; end if;
      
    if (current_pos.col >= (h_max_px_visual-1+h_front_porch_pxw)
     and current_pos.col < (h_max_px_visual-1+h_front_porch_pxw+h_sync_pxw)) then
      h_sync_is_low  <= true;  else h_sync_is_low <= false; end if;
    if (current_pos.row >= (v_max_px_visual-1+v_front_porch_pxw)
     and current_pos.row < (v_max_px_visual-1+v_front_porch_pxw+v_sync_pxw)) then
      v_sync_is_low  <= true;  else v_sync_is_low <= false; end if;
  end if;
end process;

-- Assign output ports
position <= current_pos;
vga.hsync <= '1' when not h_sync_is_low else '0';
vga.vsync <= '1' when not v_sync_is_low else '0';
vga.blank <= '1' when ((not h_blank_is_low) or (not v_blank_is_low)) else '0';

end vga_signal_generator_arch;
