library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Top is
    port (
        ADC_CLK_10    : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;

        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);

        KEY : in std_logic_vector(1 downto 0);

        LEDR : out std_logic_vector(9 downto 0);

        SW : in std_logic_vector(9 downto 0);

        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;

        GSENSOR_CS_N : out std_logic;
        GSENSOR_INT  : in std_logic;
        GSENSOR_SCLK : out std_logic;
        GSENSOR_SDI  : inout std_logic;
        GSENSOR_SDO  : inout std_logic;

        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic
    );
end entity Top;


architecture behavioral of Top is

    component GameEngine is
        port (
            clk   : in std_logic;
            rst_n : in std_logic;

            -- Graphics Engine port group
            gfx_en        : out std_logic;
            gfx_blk_num_n : out std_logic;
            gfx_x         : out std_logic_vector(3 downto 0);
            gfx_y         : out std_logic_vector(3 downto 0);
            gfx_data      : in std_logic_vector(3 downto 0);

            -- RNG port group
            rng_en : out std_logic;
            rng_q  : in std_logic_vector(7 downto 0);

            -- Audio Engine port group
            aud_en  : out std_logic;
            aud_sel : out std_logic_vector(3 downto 0);

            -- Controls port group
            start_btn   : in std_logic;
            dir_control : in std_logic_vector(11 downto 0)
        );
        end component GrameEngine;

    component GraphicsEngine is
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
            vga_rgb   : out std_logic
        );
    end component GraphicsEngine;

    component VGA is 
        port (
            pxclk : in std_logic;
            rst_n : in std_logic;
            xaddr : out unsigned(9 downto 0);
            yaddr : out unsigned(8 downto 0);
            addr_valid : out std_logic;
            HS : out std_logic;
            VS : out std_logic
        );
    end component VGA;

begin
    

end architecture behavioral;
