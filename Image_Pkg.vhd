library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Image_Pkg is

    -- =============================================================
    -- System Constants
    -- =============================================================
    constant IMAGE_WIDTH   : integer := 256;
    constant IMAGE_HEIGHT  : integer := 256;
    constant COLOR_DEPTH   : integer := 5;   -- 5 bits per pixel
    constant KERNEL_SIZE   : integer := 3;   -- Mask size (Must be Odd: 3, 5, 7...)
    
    -- Derived Constant: The width of a standard data row (1280 bits)
    constant ROW_BIT_WIDTH : integer := IMAGE_WIDTH * COLOR_DEPTH;

    -- =============================================================
    -- Type Definitions
    -- =============================================================
    -- 1. Single pixel type
    subtype pixel_t is std_logic_vector(COLOR_DEPTH-1 downto 0);
    
    -- 2. Array for a SINGLE row of the kernel (e.g., 1x3 pixels)
    type row_window_t is array (0 to KERNEL_SIZE-1) of pixel_t;

    -- 3. Array for the FULL kernel (e.g., 3x3 pixels) - Array of rows
    type kernel_window_t is array (0 to KERNEL_SIZE-1) of row_window_t;

    -- =============================================================
    -- Function Declarations
    -- =============================================================
    
    -- Sorts an array of pixels (Generic Even-Odd Sort algorithm)
    function Sort_Even_Odd(
        arr_in : row_window_t
    ) return row_window_t;

    -- Finds the median of a single row vector
    function Median_Of_Row(
        row_pixels : row_window_t
    ) return pixel_t;

    -- Finds the "Median of Medians" for the full 2D kernel (Generic)
    function Compute_Pseudo_Median(
        k_window : kernel_window_t
    ) return pixel_t;

end package Image_Pkg;

package body Image_Pkg is

    -- =============================================================
    -- Implementation: Generic Even-Odd Sort
    -- This generates a sorting network (Compare-Swap logic)
    -- =============================================================
    function Sort_Even_Odd(
        arr_in : row_window_t
    ) return row_window_t is
        variable sorted_arr : row_window_t;
        variable temp       : pixel_t;
    begin
        sorted_arr := arr_in;

        -- Outer loop: Number of passes needed for the sort
        for i in 0 to KERNEL_SIZE-1 loop
            -- Inner loop: Compare and Swap adjacent pairs
            for j in 0 to KERNEL_SIZE-2 loop
                -- Even-Odd Logic: Shift comparison pairs based on pass index 'i'
                if (i mod 2) = (j mod 2) then
                    if unsigned(sorted_arr(j)) > unsigned(sorted_arr(j+1)) then
                        -- Swap elements
                        temp := sorted_arr(j);
                        sorted_arr(j) := sorted_arr(j+1);
                        sorted_arr(j+1) := temp;
                    end if;
                end if;
            end loop;
        end loop;

        return sorted_arr;
    end function;

    -- =============================================================
    -- Implementation: Median Of Row (Wrapper)
    -- =============================================================
    function Median_Of_Row(
        row_pixels : row_window_t
    ) return pixel_t is
        variable sorted_row : row_window_t;
    begin
        -- 1. Sort the array
        sorted_row := Sort_Even_Odd(row_pixels);
        
        -- 2. Return the middle element (Index = Size / 2)
        return sorted_row(KERNEL_SIZE / 2);
    end function;

    -- =============================================================
    -- Implementation: Generic Median of Medians (For NxN Kernel)
    -- =============================================================
    function Compute_Pseudo_Median(
        k_window : kernel_window_t
    ) return pixel_t is
        -- Variable to store the median result of each row
        variable row_medians : row_window_t; 
    begin
        -- 1. Calculate Median for each row in the kernel independently
        for i in 0 to KERNEL_SIZE-1 loop
            row_medians(i) := Median_Of_Row(k_window(i));
        end loop;

        -- 2. Calculate Median of the row medians (The final result)
        return Median_Of_Row(row_medians);
    end function;

end package body Image_Pkg;