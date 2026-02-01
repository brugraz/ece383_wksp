-- Add other colors you want to use here
-- Add other colors you want to use here
-- Add other colors you want to use here
-- Add other colors you want to use here
----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( color : out color_t;
           position: in coordinate_t;
		   trigger : in trigger_t;
           ch1 : in channel_t;
           ch2 : in channel_t);
end color_mapper;

architecture color_mapper_arch of color_mapper is

-- why are these signals and not constants
signal TRIGGER_COLOR : color_t := YELLOW; 
signal GRID_COLOR    : color_t := WHITE;
signal CH1_COLOR     : color_t := YELLOW;
signal CH2_COLOR     : color_t := GREEN;
signal BG_COLOR      : color_t := BLACK;

signal is_vertical_gridline, is_horizontal_gridline, is_within_grid, is_trigger_time, is_trigger_volt, is_ch1_line, is_ch2_line,
    is_horizontal_hash, is_vertical_hash : boolean := false;

signal current_pos : coordinate_t;
signal w_ch1       : channel_t;
signal w_ch2       : channel_t;
signal w_trigger   : trigger_t;

constant GRID_START_ROW : integer := 20;
constant GRID_STOP_ROW : integer := 420;
constant GRID_START_COL : integer := 20;
constant GRID_STOP_COL : integer := 620;
constant NUM_HORIZONTAL_GRIDBLOCKS : integer := 10;
constant NUM_VERTICAL_GRIDBLOCKS : integer := 8;
constant CENTER_COLUMN : integer := 320;
constant CENTER_ROW : integer := 220;
constant HASH_SIZE : integer := 1;
constant HASH_HORIZONTAL_SPACING : integer := 15;
constant HASH_VERTICAL_SPACING : integer := 10;

constant HORIZONTAL_GRIDBLOCK_PXW : integer := 60;
constant VERTICAL_GRIDBLOCK_PXW   : integer := 50;
constant TRIGGER_PXW : integer := 9;
constant H_HASH_WIDTH : integer := 3;
constant V_HASH_WIDTH : integer := 5;

signal trigger_taper_v : integer := TRIGGER_PXW/2;
signal trigger_taper_t : integer := TRIGGER_PXW/2;

begin

-- *** boolean *** --
-- gridlines
is_within_grid <= true when
      (current_pos.row >= GRID_START_ROW
  And current_pos.row <= GRID_STOP_ROW)
  and (current_pos.col >= GRID_START_COL
  And current_pos.col <= GRID_STOP_COL)
  else false;

is_horizontal_gridline <= true when is_within_grid 
  and ((to_integer(current_pos.row) mod vertical_gridblock_pxw) = GRID_START_ROW) else false;

is_vertical_gridline   <= true when is_within_grid 
  and ((to_integer(current_pos.col) mod horizontal_gridblock_pxw) = GRID_START_ROW) else false;

-- hashmarks
is_horizontal_hash <= true when is_within_grid
  and (((current_pos.col-GRID_START_COL) mod HASH_HORIZONTAL_SPACING) = "0")
  and (current_pos.row >= CENTER_ROW-H_HASH_WIDTH)
  and (current_pos.row <= CENTER_ROW+H_HASH_WIDTH)
  else false;

is_vertical_hash <= true when is_within_grid
  and ((current_pos.row-GRID_START_ROW) mod HASH_VERTICAL_SPACING = "0")
  and (current_pos.col >= CENTER_COLUMN-V_HASH_WIDTH)
  and (current_pos.col <= CENTER_COLUMN+V_HASH_WIDTH)
  else false;

-- channel signals
is_ch1_line <= true  when ch1.active = '1' and ch1.en = '1' else false;
is_ch2_line <= false when ch2.active = '1' and ch2.en = '1' else false;

-- triggers tapers (shape) for trigger drawing bools
trigger_taper_v <= (TRIGGER_PXW/2)-(to_integer(current_pos.col)-GRID_START_COL);
trigger_taper_t <= (TRIGGER_PXW/2)-(to_integer(current_pos.row)-GRID_START_ROW);

-- to draw triggers
is_trigger_volt <= true when is_within_grid
  and (current_pos.row >= w_trigger.v-trigger_taper_v)  
  and (current_pos.row <= w_trigger.v+trigger_taper_v)
  and (current_pos.col >= GRID_START_COL)
  and (current_pos.col <= GRID_START_COL+(TRIGGER_PXW/2)+1)
  else false;

is_trigger_time <= true when is_within_grid
  and (current_pos.col >= w_trigger.t-trigger_taper_t)
  and (current_pos.col <= w_trigger.t+trigger_taper_t)
  and (current_pos.row >= GRID_START_ROW)
  and (current_pos.row <= GRID_START_ROW+(TRIGGER_PXW/2)+1)
  else false;

-- choose color 
-- layer higher is assigned first, after each "else" is ordered another layer behind.
color <= TRIGGER_COLOR When is_trigger_time or is_trigger_volt
  else GRID_COLOR When is_horizontal_gridline or is_vertical_gridline or is_horizontal_hash or is_vertical_hash
  else CH1_COLOR  when is_ch1_line
  else CH2_COLOR  when is_ch2_line
  else BG_COLOR;
                         
-- assign IO to sigs concurrent
current_pos <= position;
w_ch1       <= ch1;
w_ch2       <= ch2;
w_trigger   <= trigger;

end color_mapper_arch;
