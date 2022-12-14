library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Top_TB is
end entity Top_TB;


architecture behavioral of Top_TB is

    constant CLK_PERIOD : time := 20 ns;

    component Top is
        port (
            ADC_CLK_10    : in std_logic := '0';
            MAX10_CLK1_50 : in std_logic;
            MAX10_CLK2_50 : in std_logic := '0';

            HEX0 : out std_logic_vector(7 downto 0);
            HEX1 : out std_logic_vector(7 downto 0);
            HEX2 : out std_logic_vector(7 downto 0);
            HEX3 : out std_logic_vector(7 downto 0);
            HEX4 : out std_logic_vector(7 downto 0);
            HEX5 : out std_logic_vector(7 downto 0);

            KEY : in std_logic_vector(1 downto 0);

            LEDR : out std_logic_vector(9 downto 0);

            SW : in std_logic_vector(9 downto 0) := (others => '0');

            VGA_R  : out std_logic_vector(3 downto 0);
            VGA_G  : out std_logic_vector(3 downto 0);
            VGA_B  : out std_logic_vector(3 downto 0);
            VGA_HS : out std_logic;
            VGA_VS : out std_logic;

            GSENSOR_CS_N : out std_logic;
            GSENSOR_INT  : in std_logic := '0';
            GSENSOR_SCLK : out std_logic;
            GSENSOR_SDI  : in std_logic := '0';
            GSENSOR_SDO  : out std_logic;

            ARDUINO_IO      : inout std_logic_vector(15 downto 0);
            ARDUINO_RESET_N : inout std_logic
        );
    end component;
    signal clk   : std_logic;
    signal key   : std_logic_vector(1 downto 0);
    signal vga_r : std_logic_vector(3 downto 0);
    signal vga_g : std_logic_vector(3 downto 0);
    signal vga_b : std_logic_vector(3 downto 0);
    signal HS    : std_logic;
    signal VS    : std_logic;

    signal rst : std_logic;
    signal rgb : std_logic_vector(11 downto 0);

begin

    key <= not ('0' & rst);
    rgb <= vga_r & vga_g & vga_b;

    uut : Top
        port map (
            MAX10_CLK1_50   => clk,
            KEY             => key,
            VGA_R           => vga_r,
            VGA_G           => vga_g,
            VGA_B           => vga_b,
            VGA_HS          => HS,
            VGA_VS          => VS
        );

    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process; -- clk_proc

    stim_proc : process
    begin

        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';

        wait for 1 sec;

    end process; -- stim_proc

end architecture behavioral;
