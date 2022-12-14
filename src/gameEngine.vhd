library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GameEngine is
    port (
        clk   : in std_logic;
        rst_n : in std_logic;
        VS    : in std_logic;

        -- Graphics Engine port group
        en          : in std_logic;
        blk_score_n : in std_logic;
        hpos        : in unsigned(3 downto 0);
        vpos        : in unsigned(3 downto 0);
        data        : out std_logic_vector(3 downto 0);

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
end entity GameEngine;

architecture behavioral of GameEngine is

    -- 0 black
    -- 1 red
    -- 2 green
    -- 3 blue
    -- 4 yellow
    type BLOCK_ROW_T is array(0 to 8) of std_logic_vector(3 downto 0);
    type BLOCK_ARR_T is array(0 to 13) of BLOCK_ROW_T;
    signal block_arr : BLOCK_ARR_T := (
        (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- first row
        (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- second row
        (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- third row
        (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1"), -- fourth row
        (x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2"), -- fifth row
        (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- 6th row
        (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- 7th row
        (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- 8th row
        (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1"), -- 9th row
        (x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2"), -- 10th row
        (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- 11th row
        (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- 12th row
        (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- 13th row
        (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1") -- 14th row
    );

    signal hpos_int : natural range 0 to 8;
    signal vpos_int : natural range 0 to 13;

begin

    hpos_int <= to_integer(hpos);
    vpos_int <= to_integer(vpos);

    main_proc : process(all)
    begin
        if (rst_n = '0') then
            data <= (others => '0');
        else
            if (en = '1') then
                if (blk_score_n = '1') then -- send block color data
                    case hpos is
                        when x"0" => data <= block_arr(vpos_int)(0);
                        when x"1" => data <= block_arr(vpos_int)(1);
                        when x"2" => data <= block_arr(vpos_int)(2);
                        when x"3" => data <= block_arr(vpos_int)(3);
                        when x"4" => data <= block_arr(vpos_int)(4);
                        when x"5" => data <= block_arr(vpos_int)(5);
                        when x"6" => data <= block_arr(vpos_int)(6);
                        when x"7" => data <= block_arr(vpos_int)(7);
                        when x"8" => data <= block_arr(vpos_int)(8);
                        when others => data <= (others => '0');
                    end case;
                    -- data <= block_arr(vpos_int)(hpos_int); -- Doesn't work, but above case statement does...?
                else
                    data <= std_logic_vector(hpos);
                end if;
            else
                data <= (others => '0');
            end if;
        end if; -- (rst_n = '0')
    end process;

end architecture behavioral;