### Lab 1: Bruno Graziano, ECE 383

#### Introduction

We need to display a grid that is fitting for a two-channel oscilloscope on a 640x480 VGA screen. To test the channels, we will include two hard-coded lines that are enabled upon user input. There will also be trigger marks that are movable by the pressing of directional buttons. The horizontal axis will be time, and the vertical voltage. The VGA synchonization lab will consist of interfacing layers of modules that contribute to an overall design whose gluing of its interior components and logic of most interior components are entirely written by student.

#### Design/Implementation

    ![hw5 diagram](images/

    ![block diagram](images/

##### About each component

`vga_signal_generator` outputs an increasing position (increasing in columns one column a single pixel, according to the clock cycle, and after the highest column, ticking up a row, and after the highest row, ticking back to row 0 and column 0) as well as vga characteristic states like `h_sync` `v_sync` and `blank` with logic within that determines when during the row and column counts each signal would be high or low. The inputs are `clk` and `reset_n` and the outputs are `position` (a coordinate record of unsigned row and col) and `vga` (a VGA state record for `h_sync`, `v_sync` and `blank`).




#### Test/Debug

#### Results

#### Conclusion
