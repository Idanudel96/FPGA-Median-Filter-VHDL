library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Image_Procesing_Top is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        start          : in  std_logic;
        done           : out std_logic;
        -- ?????? ?????? ???? ?-TB (????? 3 ???? MIF)
        mon_ram_wren   : out std_logic;
        mon_ram_addr   : out std_logic_vector(7 downto 0);
        mon_r_data     : out std_logic_vector(1279 downto 0);
        mon_g_data     : out std_logic_vector(1279 downto 0);
        mon_b_data     : out std_logic_vector(1279 downto 0)
    );
end Image_Procesing_Top;

architecture Behavioral of Image_Procesing_Top is
    -- ?????? ???? ??????? ??-FSM
    signal w_rom_addr, w_ram_addr : std_logic_vector(7 downto 0);
    signal w_en_rom, w_wr_ram     : std_logic;

    -- ??????? ???? ???? ???? (Red)
    signal r_rom_q, r_filtered    : std_logic_vector(1279 downto 0);
    signal r_low, r_mid, r_high   : std_logic_vector(1289 downto 0);

    -- ??????? ???? ???? ???? (Green)
    signal g_rom_q, g_filtered    : std_logic_vector(1279 downto 0);
    signal g_low, g_mid, g_high   : std_logic_vector(1289 downto 0);

    -- ??????? ???? ???? ???? (Blue)
    signal b_rom_q, b_filtered    : std_logic_vector(1279 downto 0);
    signal b_low, b_mid, b_high   : std_logic_vector(1289 downto 0);

begin
    -- ????? ?????? ??????
    mon_ram_wren <= w_wr_ram;
    mon_ram_addr <= w_ram_addr;
    mon_r_data   <= r_filtered;
    mon_g_data   <= g_filtered;
    mon_b_data   <= b_filtered;

    -- ??? FSM ???? ????? ?? ???? ??????
    U_FSM : entity work.Filter_FSM
    port map (
        clk => clk, reset => rst, start => start,
        en_rom => w_en_rom, wr_RAM => w_wr_ram,
        en_rom_counter => w_rom_addr, en_RAM_counter => w_ram_addr,
        done => done
    );

    -------------------------------------------------------
    -- ???? ???? (Red Channel)
    -------------------------------------------------------
    U_ROM_R : entity work.ROM_1280_256_Port_1
    generic map ( init_file_name => "R_noise_matrix.mif" )
    port map ( aclr => rst, address => w_rom_addr, clock => clk, q => r_rom_q );

    U_Buf_R : entity work.Buffer1
    generic map ( COLOR_DEPTH => 5, ROW_WIDTH => 256 )
    port map ( clk => clk, rst => rst, current_row => r_rom_q, 
               low_row => r_low, mid_row => r_mid, high_row => r_high );

    U_Pipe_R : entity work.Parallel_Filter_Row
    port map ( row1_padded => r_low, row2_padded => r_mid, row3_padded => r_high, 
               data_out => r_filtered );

    U_RAM_R : entity work.ram_1280_256
    generic map ( inst_name => "RAM_R" )
    port map ( aclr => rst, address => w_ram_addr, clock => clk, 
               data => r_filtered, wren => w_wr_ram, q => open );

    -------------------------------------------------------
    -- ???? ???? (Green Channel)
    -------------------------------------------------------
    U_ROM_G : entity work.ROM_1280_256_Port_1
    generic map ( init_file_name => "G_noise_matrix.mif" )
    port map ( aclr => rst, address => w_rom_addr, clock => clk, q => g_rom_q );

    U_Buf_G : entity work.Buffer1
    generic map ( COLOR_DEPTH => 5, ROW_WIDTH => 256 )
    port map ( clk => clk, rst => rst, current_row => g_rom_q, 
               low_row => g_low, mid_row => g_mid, high_row => g_high );

    U_Pipe_G : entity work.Parallel_Filter_Row
    port map ( row1_padded => g_low, row2_padded => g_mid, row3_padded => g_high, 
               data_out => g_filtered );

    U_RAM_G : entity work.ram_1280_256
    generic map ( inst_name => "RAM_G" )
    port map ( aclr => rst, address => w_ram_addr, clock => clk, 
               data => g_filtered, wren => w_wr_ram, q => open );

    -------------------------------------------------------
    -- ???? ???? (Blue Channel)
    -------------------------------------------------------
    U_ROM_B : entity work.ROM_1280_256_Port_1
    generic map ( init_file_name => "B_noise_matrix.mif" )
    port map ( aclr => rst, address => w_rom_addr, clock => clk, q => b_rom_q );

    U_Buf_B : entity work.Buffer1
    generic map ( COLOR_DEPTH => 5, ROW_WIDTH => 256 )
    port map ( clk => clk, rst => rst, current_row => b_rom_q, 
               low_row => b_low, mid_row => b_mid, high_row => b_high );

    U_Pipe_B : entity work.Parallel_Filter_Row
    port map ( row1_padded => b_low, row2_padded => b_mid, row3_padded => b_high, 
               data_out => b_filtered );

    U_RAM_B : entity work.ram_1280_256
    generic map ( inst_name => "RAM_B" )
    port map ( aclr => rst, address => w_ram_addr, clock => clk, 
               data => b_filtered, wren => w_wr_ram, q => open );

end Behavioral;