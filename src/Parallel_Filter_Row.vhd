library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Image_Pkg.ALL; -- Use our package

entity Parallel_Filter_Row is
    generic (
        -- Standard row width (256 * 5 = 1280)
        INPUT_WIDTH : integer := IMAGE_WIDTH * COLOR_DEPTH;
        -- Padded width: 1280 + 2*5 = 1290
        PADDED_WIDTH: integer := (IMAGE_WIDTH * COLOR_DEPTH) + (2 * COLOR_DEPTH)
    );
    port (
        -- Inputs: 3 Padded rows from Buffer1
        -- (Includes: Left Padding + Row Data + Right Padding)
        row1_padded : in std_logic_vector(PADDED_WIDTH - 1 downto 0);
        row2_padded : in std_logic_vector(PADDED_WIDTH - 1 downto 0);
        row3_padded : in std_logic_vector(PADDED_WIDTH - 1 downto 0);

        -- Output: 1 Clean row to RAM (No padding)
        data_out    : out std_logic_vector(INPUT_WIDTH - 1 downto 0)
    );
end Parallel_Filter_Row;

architecture Behavioral of Parallel_Filter_Row is

begin

    -- =========================================================================
    -- Parallel Generation: Creates 256 instances of the Median Filter logic
    -- =========================================================================
    Gen_Filter_Pixels: for i in 0 to IMAGE_WIDTH-1 generate
        
        -- Local signals for the current pixel 'i'
        signal window_pixels : kernel_window_t;
        signal median_result : pixel_t;
        
    begin
        
        -- 1. Extract the 3x3 Window
        -- ---------------------------------------------------------------------
        -- Because 'row_padded' has extra pixels at the bottom (LSB) and top (MSB),
        -- we can simply slide a window of size (3 * COLOR_DEPTH) across it.
        -- 
        -- i=0 (First pixel): Needs bits 0..14 (RightPad, Pixel0, Pixel1)
        -- i=1 (Second pixel): Needs bits 5..19 (Pixel0, Pixel1, Pixel2)
        -- ...
        -- This maps perfectly to: start_bit = i * COLOR_DEPTH
        -- ---------------------------------------------------------------------
        
        process(row1_padded, row2_padded, row3_padded)
            variable bit_idx : integer;
        begin
             -- Loop to grab the 3 horizontal pixels (Left, Center, Right)
             for k in 0 to 2 loop
                 -- Calculate the starting bit index in the padded vector
                 bit_idx := (i + k) * COLOR_DEPTH; 
                 
                 -- Extract pixels for Row 1, 2, and 3
                 window_pixels(0)(k) <= row1_padded(bit_idx + COLOR_DEPTH - 1 downto bit_idx);
                 window_pixels(1)(k) <= row2_padded(bit_idx + COLOR_DEPTH - 1 downto bit_idx);
                 window_pixels(2)(k) <= row3_padded(bit_idx + COLOR_DEPTH - 1 downto bit_idx);
             end loop;
        end process;

        -- 2. Compute the Median (Pure Combinational Logic)
        -- ---------------------------------------------------------------------
        median_result <= Compute_Pseudo_Median(window_pixels);

        -- 3. Assign Result to Output Vector
        -- ---------------------------------------------------------------------
        -- Place the result into the correct position in the 1280-bit output bus
        data_out((i * COLOR_DEPTH) + COLOR_DEPTH - 1 downto (i * COLOR_DEPTH)) <= median_result;

    end generate Gen_Filter_Pixels;

end Behavioral;