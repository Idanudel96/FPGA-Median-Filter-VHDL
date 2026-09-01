library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Filter_FSM is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        start            : in  std_logic;
        en_rom           : out std_logic;
        wr_RAM           : out std_logic;
        en_rom_counter   : out std_logic_vector(7 downto 0);
        en_RAM_counter   : out std_logic_vector(7 downto 0);
        done             : out std_logic
    );
end Filter_FSM;

architecture arc_Filter_FSM of Filter_FSM is
    type FSM_state is (IDLE, FIRST_ROW, LOAD_ROWS, LAST_ROW);
    signal CS : FSM_state;
    signal rom_cnt_internal : unsigned(7 downto 0);
    signal ram_cnt_internal : unsigned(7 downto 0);
begin
    en_rom_counter <= std_logic_vector(rom_cnt_internal);
    en_RAM_counter <= std_logic_vector(ram_cnt_internal);

    process(clk, reset)
        variable counter : integer range 0 to 265;
    begin
        if (reset = '1') then
            CS <= IDLE;
            done <= '0';
            en_rom <= '0';
            wr_RAM <= '0';
            rom_cnt_internal <= (others => '0');
            ram_cnt_internal <= (others => '0');
            counter := 0;
        elsif rising_edge(clk) then
            case CS is
                when IDLE =>
                    done <= '0';
                    if (start = '1') then
                        en_rom <= '1';
                        rom_cnt_internal <= (others => '0');
                        ram_cnt_internal <= (others => '0');
                        counter := 0;
                        CS <= FIRST_ROW;
                    else
                        CS <= IDLE;
                    end if;

                when FIRST_ROW =>
                    if (counter < 3) then 
                        rom_cnt_internal <= rom_cnt_internal + 1;
                        counter := counter + 1;
                        CS <= FIRST_ROW;
                    else
                        CS <= LOAD_ROWS;
                    end if;

                when LOAD_ROWS =>
                    if (counter < 256) then
                        rom_cnt_internal <= to_unsigned(counter, 8);
                        wr_RAM <= '1';
                        -- ?????: ????? ??? ????? ?-to_unsigned
                        if counter >= 4 then
                            ram_cnt_internal <= to_unsigned(counter - 4, 8); 
                        else
                            ram_cnt_internal <= (others => '0');
                        end if;
                        counter := counter + 1;
                        CS <= LOAD_ROWS;
                    else
                        en_rom <= '0';
                        CS <= LAST_ROW;
                    end if;

                when LAST_ROW =>
                    if (counter < 260) then
                        wr_RAM <= '1';
                        -- ?????: ????? ??? ????? ?-to_unsigned
                        if counter >= 4 then
                            ram_cnt_internal <= to_unsigned(counter - 4, 8);
                        else
                            ram_cnt_internal <= (others => '0');
                        end if;
                        counter := counter + 1;
                        CS <= LAST_ROW;
                    else
                        wr_RAM <= '0';
                        done <= '1';
                        CS <= IDLE; 
                    end if;
            end case;
        end if;
    end process;
end architecture;