library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Buffer1 is
    generic (
        COLOR_DEPTH : integer := 5;    -- Number of bits
        ROW_WIDTH   : integer := 256   -- Simplified for testing
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        current_row: in  std_logic_vector((ROW_WIDTH * COLOR_DEPTH) - 1 downto 0);
        low_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0);
        mid_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0);
        high_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0)
    );
end Buffer1;

architecture Behavioral of Buffer1 is
    signal low_r, mid_r, high_r: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) - 1 downto 0);
    signal first_pixel_low, last_pixel_low: std_logic_vector(COLOR_DEPTH - 1 downto 0);
    signal first_pixel_mid, last_pixel_mid: std_logic_vector(COLOR_DEPTH - 1 downto 0);
    signal first_pixel_hig, last_pixel_hig: std_logic_vector(COLOR_DEPTH - 1 downto 0);
begin

    -- Process 1: Propagate rows
    process(clk, rst)
    begin
        if rst = '1' then
            low_r <= (others => '0');
            mid_r <= (others => '0');
            high_r <= (others => '0');
        elsif (rising_edge(clk)) then
            high_r <= mid_r;		   --		|
            mid_r <= low_r;		   --		|
            low_r <= current_row;  --		V
        end if;
    end process;

    -- Process 2: Extract first and last pixels
    process(low_r, mid_r, high_r)
    begin
        -- Padding for low_row
        first_pixel_low <= low_r((ROW_WIDTH * COLOR_DEPTH) - 1 downto (ROW_WIDTH * COLOR_DEPTH) - COLOR_DEPTH);
        last_pixel_low <= low_r(COLOR_DEPTH - 1 downto 0);

        -- Padding for mid_row
        first_pixel_mid <= mid_r((ROW_WIDTH * COLOR_DEPTH) - 1 downto (ROW_WIDTH * COLOR_DEPTH) - COLOR_DEPTH);
        last_pixel_mid <= mid_r(COLOR_DEPTH - 1 downto 0);

        -- Padding for high_row
        first_pixel_hig <= high_r((ROW_WIDTH * COLOR_DEPTH) - 1 downto (ROW_WIDTH * COLOR_DEPTH) - COLOR_DEPTH);
        last_pixel_hig <= high_r(COLOR_DEPTH - 1 downto 0);
    end process;

    -- Concatenate first_pixel, row, and last_pixel
    low_row <= first_pixel_low & low_r & last_pixel_low;
    mid_row <= first_pixel_mid & mid_r & last_pixel_mid;
    high_row <= first_pixel_hig & high_r & last_pixel_hig;

end Behavioral;

