library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ColorLUT is
    port (
      en  : std_logic;
      sel : unsigned(2 downto 0);
      rgb : std_logic_vector(23 downto 0)
    );
end entity ColorLUT;


architecture behavioral of ColorLUT is

    type COLOR_T is array(0 to 4) of std_logic_vector(23 to 0);
    constant COLOR_ARRAY : COLOR_T := (
        (X"000000", -- black
         X"FF0000", -- red
         X"00FF00", -- green
         X"0000FF", -- blue
         X"FFFF00" -- yellow
    ));

    signal sel_color   : natural;

begin

    sel_color   <= to_integer(sel);

    rgb <= COLOR_ARRAY(0) when (en = '0') else COLOR_ARRAY(sel_color);

end architecture behavioral;
