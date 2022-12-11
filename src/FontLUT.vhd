library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FontLUT is
    port (
        en    : in std_logic;
        sel   : in unsigned(3 downto 0);
        xaddr : in unsigned(2 downto 0);
        yaddr : in unsigned(3 downto 0);
        px    : out std_logic
    );
end entity FontLUT;


architecture behavioral of FontLUT is

    type FONT_T is array(0 to 15) of std_logic_vector(0 to 7);
    type FONT_ARRAY_T is array(0 to 9) of FONT_T;
    constant FONT_ARRAY : FONT_ARRAY_T := (
        (x"3C",x"3C",x"42",x"42",x"46",x"46",x"5A",x"5A",x"62",x"62",x"42",x"42",x"3C",x"3C",x"00",x"00"), -- 0
        (x"08",x"08",x"18",x"18",x"08",x"08",x"08",x"08",x"08",x"08",x"08",x"08",x"1C",x"1C",x"00",x"00"), -- 1
        (x"3C",x"3C",x"42",x"42",x"02",x"02",x"1C",x"1C",x"20",x"20",x"40",x"40",x"7E",x"7E",x"00",x"00"), -- 2
        (x"7E",x"7E",x"02",x"02",x"04",x"04",x"1C",x"1C",x"02",x"02",x"42",x"42",x"3C",x"3C",x"00",x"00"), -- 3
        (x"04",x"04",x"0C",x"0C",x"14",x"14",x"24",x"24",x"7E",x"7E",x"04",x"04",x"04",x"04",x"00",x"00"), -- 4
        (x"7E",x"7E",x"40",x"40",x"7C",x"7C",x"02",x"02",x"02",x"02",x"42",x"42",x"3C",x"3C",x"00",x"00"), -- 5
        (x"1E",x"1E",x"20",x"20",x"40",x"40",x"7C",x"7C",x"42",x"42",x"42",x"42",x"3C",x"3C",x"00",x"00"), -- 6
        (x"7E",x"7E",x"02",x"02",x"04",x"04",x"08",x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"00",x"00"), -- 7
        (x"3C",x"3C",x"42",x"42",x"42",x"42",x"3C",x"3C",x"42",x"42",x"42",x"42",x"3C",x"3C",x"00",x"00"), -- 8
        (x"3C",x"3C",x"42",x"42",x"42",x"42",x"3E",x"3E",x"02",x"02",x"04",x"04",x"78",x"78",x"00",x"00")  -- 9
    );

    signal sel_int   : natural;
    signal xaddr_int : natural;
    signal yaddr_int : natural;

begin

    sel_int   <= to_integer(sel);
    xaddr_int <= to_integer(xaddr);
    yaddr_int <= to_integer(yaddr);

    px <= '0' when (en = '0') else FONT_ARRAY(sel_int)(yaddr_int)(xaddr_int);

end architecture behavioral;
