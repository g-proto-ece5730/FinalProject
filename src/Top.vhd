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
        GSENSOR_SDI  : in std_logic;
        GSENSOR_SDO  : out std_logic;

        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic
    );
end entity Top;


architecture behavioral of Top is

    --------------------------------------------------
    -- BEGIN: COMPONENTS
    --------------------------------------------------
    component ADC_PLL
        port (
            inclk0  : in std_logic := '0';
            c0      : out std_logic;
            locked  : out std_logic 
        );
    end component;
    signal adc_pll_clk    : std_logic;
    signal adc_pll_locked : std_logic;

    component PLL is
        port (
            areset  : in std_logic := '0';
            inclk0  : in std_logic := '0';
            c0      : out std_logic
        );
    end component;
    signal pxclk : std_logic;

    component ADC_Controller is
        generic (
            CLK_FREQ : integer;
            SAMPLE_FREQ : integer
        );
        port (
            clk             : in std_logic;
            rst_n           : in std_logic;
            adc_pll_clk     : in std_logic;
            adc_pll_locked  : in std_logic;
            dout            : out std_logic_vector(11 downto 0)
        );
    end component ADC_Controller;

    component GameEngine is
        port (
            clk   : in std_logic;
            rst_n : in std_logic;
            VS    : in std_logic;

            -- Graphics Engine port group
            game_en          : in std_logic;
            game_blk_score_n : in std_logic;
            game_hpos        : in unsigned(3 downto 0);
            game_vpos        : in unsigned(3 downto 0);
            game_data        : out std_logic_vector(3 downto 0);

            -- Audio Engine port group
            aud_en  : out std_logic;
            aud_sel : out std_logic_vector(3 downto 0);

            -- Controls port group
            start_btn   : in std_logic;
            dir_control : in std_logic_vector(11 downto 0)
        );
    end component GameEngine;
    signal game_en          : std_logic;
    signal game_blk_score_n : std_logic;
    signal game_hpos        : unsigned(3 downto 0);
    signal game_vpos        : unsigned(3 downto 0);
    signal game_data        : std_logic_vector(3 downto 0);
    signal start_btn        : std_logic;
    signal dir_control      : std_logic_vector(11 downto 0);

    component GraphicsEngine is
        port (
            pxclk : in std_logic;
            rst_n : in std_logic;
    
            -- Game Engine port group
            game_en          : out std_logic;
            game_blk_score_n : out std_logic;
            game_hpos        : out unsigned(3 downto 0);
            game_vpos        : out unsigned(3 downto 0);
            game_data        : in std_logic_vector(3 downto 0);
    
            -- VGA port group
            vga_x     : in unsigned(9 downto 0);
            vga_y     : in unsigned(8 downto 0);
            vga_valid : in std_logic;
            vga_rgb   : out std_logic_vector(23 downto 0)
        );
    end component GraphicsEngine;
    signal vga_rgb : std_logic_vector(23 downto 0);

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
    signal vga_x     : unsigned(9 downto 0);
    signal vga_y     : unsigned(8 downto 0);
    signal vga_valid : std_logic;
    --------------------------------------------------
    -- END: COMPONENTS
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: INTERNAL SIGNALS
    --------------------------------------------------
    signal rst   : std_logic;
    signal rst_n : std_logic;
    signal VS    : std_logic;
    --------------------------------------------------
    -- END: INTERNAL SIGNALS
    --------------------------------------------------

begin

    --------------------------------------------------
    -- BEGIN: WIRING
    --------------------------------------------------
    rst   <= not key(0);
    rst_n <= key(0);
    start_btn <= not key(1);
    VGA_R <= vga_rgb(23 downto 20) when (vga_valid = '1') else (others => '0');
    VGA_G <= vga_rgb(15 downto 12) when (vga_valid = '1') else (others => '0');
    VGA_B <= vga_rgb(7  downto 4)  when (vga_valid = '1') else (others => '0');
    VS    <= VGA_VS;
    --------------------------------------------------
    -- END: WIRING
    --------------------------------------------------

    --------------------------------------------------
    -- BEGIN: INSTANTIATIONS
    --------------------------------------------------
    PLL0 : ADC_PLL
        port map (
            inclk0  => ADC_CLK_10,
            c0      => adc_pll_clk,
            locked  => adc_pll_locked
        );

    PLL_1 : PLL
        port map (
            areset  => '0',
            inclk0  => MAX10_CLK1_50,
            c0      => pxclk
        );

    ADC_Ctrl_0 : ADC_Controller 
        generic map (
            CLK_FREQ => 50_000_000,
            SAMPLE_FREQ => 10_000
        )
        port map(
            clk             => MAX10_CLK1_50,
            rst_n           => rst_n,
            adc_pll_clk     => adc_pll_clk,
            adc_pll_locked  => adc_pll_locked,
            dout            => dir_control
        );

    GameEngine_0 : GameEngine
        port map (
            clk             => pxclk,
            rst_n           => rst_n,
            VS              => VS,
            game_en         => game_en,
            game_blk_score_n=> game_blk_score_n,
            game_hpos       => game_hpos,
            game_vpos       => game_vpos,
            game_data       => game_data,
            start_btn       => '0',
            dir_control     => dir_control
        );

    GraphicsEngine_0 : GraphicsEngine
        port map (
            pxclk            => pxclk,
            rst_n            => rst_n,
            game_en          => game_en,
            game_blk_score_n => game_blk_score_n,
            game_hpos        => game_hpos,
            game_vpos        => game_vpos,
            game_data        => game_data,
            vga_x            => vga_x,
            vga_y            => vga_y,
            vga_valid        => vga_valid,
            vga_rgb          => vga_rgb
        );

    VGA_0 : VGA
        port map (
            pxclk       => pxclk,
            rst_n       => rst_n,
            xaddr       => vga_x,
            yaddr       => vga_y,
            addr_valid  => vga_valid,
            HS          => VGA_HS,
            VS          => VGA_VS
        );
    --------------------------------------------------
    -- END: INSTANTIATIONS
    --------------------------------------------------

end architecture behavioral;
