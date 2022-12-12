library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity GraphicsEngine is
    port (
        pxclk : in std_logic;
        rst_n : in std_logic;

        -- Game Engine port group
        game_en         : out std_logic;
        game_blk_num_n  : out std_logic;
        game_x          : out std_logic_vector(3 downto 0);
        game_y          : out std_logic_vector(3 downto 0);
        game_data       : in std_logic_vector(3 downto 0);

        -- VGA port group
        vga_x     : in std_logic_vector(9 downto 0);
        vga_y     : in std_logic_vector(8 downto 0);
        vga_valid : in std_logic;
        vga_rgb   : out std_logic;
    );
end entity GraphicsEngine;


architecture behavioral of GraphicsEngine is

    component FontLUT is
        port (
            en      : in std_logic;
            sel     : in unsigned(3 downto 0);
            xaddr   : in unsigned(2 downto 0);
            yaddr   : in unsigned(3 downto 0);
            px      : out std_logic
        );
    end component FontLUT;
    signal font_en  : std_logic;
    signal font_sel : unsigned(3 downto 0);
    signal font_x   : unsigned(2 downto 0);
    signal font_y   : unsigned(3 downto 0);
    signal font_px  : std_logic;

    component ColorLUT is
        port (
            en  : std_logic;
            sel : std_logic_vector(2 downto 0);
            rgb : std_logic_vector(23 downto 0)
        );
    end component ColorLUT;
    signal color_en  : std_logic;
    signal color_sel : std_logic_vector(2 downto 0);
    signal color_rgb : std_logic_vector(23 downto 0);

    -- Constants
    constant BLOCK_W    : natural := 32;
    constant BLOCK_H    : natural := 32;
    constant GRID_W     : natural := 9;
    constant GRID_H     : natural := 14;
    constant GRID_X     : natural := 177;
    constant GRID_Y     : natural := 17
    constant GRID_X2    : natural := GRID_X + GRID_W;
    constant GRIX_Y2    : natural := GRIX_Y + GRIX_H;
    constant BORDER_W   : natural := 290;
    constant BORDER_H   : natural := 450;
    constant BORDER_X   : natural := GRID_X - 1;
    constant BORDER_Y   : natural := GRID_Y - 1;
    constant BORDER_X2  : nautral := BORDER_X + BORDER_W;
    constant BORDER_Y2  : natural := BORDER_Y + BORDER_H;
    constant FONT_W     : natural := 8;
    constant FONT_H     : natural := 16;
    constant FONT_SCALE : natural := 3;
    constant SCORE_W    : natural := 6;
    constant SCORE_X    : natural := 480;
    constant SCORE_Y    : natural := 320;
    constant SCORE_X2   : natural := SCORE_X + (6 * FONT_W * FONT_SCALE);
    constant tPREFETCH  : natural := 3;

    -- Internal registers
    signal font_row : natural range 0 to FONT_H-1;
    signal font_col : natural range 0 to FONT_W-1;
    signal blk_row  : natural range 0 to BLOCK_W-1;
    signal blk_col  : natural range 0 to BLOCK_H-1;
    signal x_count  : natural range 0 to BLOCK_W-1;
    signal y_count  : natural range 0 to BLOCK_H-1;
    signal rgb_buff : std_logic_vector(23 downto 0);

    -- Internal wires

begin

    FontLUT0 : FontLUT
        port map (
            en    => font_en,
            sel   => font_sel,
            xaddr => font_x,
            yaddr => font_y,
            px    => font_px
        );

    ColorLUT0 : ColorLUT
        port map (
            en  => color_en,
            sel => color_sel,
            rgb => color_rgb
        );

    prefetch_proc : process (pxclk)
    begin
        if rising_edge(pxclk) then
            if (rst_n = '0') then
                rgb_buff <= (others => '0');
            else
                -- Fetch stuff
            end if; -- (rst_n = '0')
        end if; -- rising_edge(pxclk)
    end process; -- prefecth_proc

    draw_proc : process (pxclk)
    begin
        if rising_edge(pxclk) then
            if (rst_n = '0') then
                font_en     <= '0';
                color_en    <= '0';
                game_en     <= '0';
                font_row    <= (others => '0');
                font_col    <= (others => '0');
                blk_row     <= (others => '0');
                blk_col     <= (others => '0');
                x_count     <= (others => '0');
                y_count     <= (others => '0');
                rgb_vga     <= (others => '0');
            else

                -- Vertical Borders
                if (vga_x = BORDER_X or vga_x = BORDER_X2) then
                    if (vga_y >= BORDER_Y and vga_y <= BORDER_Y2) then
                        vga_rgb <= (others => '1');
                    end if;

                -- Horizontal Border
                elsif (vga_y = BORDER_Y2 and vga_x >= BORDER_X and vga_x <= BORDER_X2) then
                    vga_rgb <= (others => '1');
                
                -- Black background
                else
                    vga_rgb <= (others => '0');
                end if;

            end if; -- (rst_n = '0')
        end if; -- rising_edge(pxclk)
    end process; -- border_proc

end architecture behavioral;
