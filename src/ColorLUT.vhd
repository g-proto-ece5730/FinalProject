library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ColorLUT is
    port (
      en  : in std_logic;
      sel : in std_logic_vector(2 downto 0);
      rgb : out std_logic_vector(23 downto 0)
    );
end entity ColorLUT;


architecture behavioral of ColorLUT is

    type COLOR_ARR_T is array(0 to 4) of std_logic_vector(23 downto 0);
    constant COLOR_ARR : COLOR_ARR_T := (
        x"000000", -- black
        x"FF0000", -- red
        x"00FF00", -- green
        x"0000FF", -- blue
        x"FFFF00"  -- yellow
    );

begin

    rgb <= COLOR_ARR(to_integer(unsigned(sel))) when (en = '1') else (others => '0');

end architecture behavioral;
