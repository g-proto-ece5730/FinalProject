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

end architecture behavioral;
