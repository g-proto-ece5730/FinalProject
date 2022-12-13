library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GameEngine is
  port (
    clk   : in std_logic;
    rst_n : in std_logic;
    V     : in std_logic;

    -- Graphics Engine port group
    game_en        : in std_logic;
    game_blk_score_n : in std_logic;
    game_hpos         : in unsigned(3 downto 0);
    game_vpos         : in unsigned(3 downto 0);
    game_data      : out std_logic_vector(3 downto 0);

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

  signal cur_game_data, prev_game_data : std_logic_vector(3 downto 0);
  signal x, y : unsigned(3 downto 0);
  -- 0 black
  -- 1 red
  -- 2 green
  -- 3 blue
  -- 4 yellow
  type BLOCK_ROW_T is array(0 to 8) of std_logic_vector(3 downto 0);
  type BLOCK_ARR_T is array(0 to 13) of BLOCK_ROW_T;
  signal BLOCK_ARR : BLOCK_ARR_T := (
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

begin

  game_data <= cur_game_data;
  x <= game_x;
  y <= game_y;

  main_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        cur_game_data <= (others => '0');
        -- prev_game_data <= (others => '0');
      else
        if (game_en = '1') then
          if (game_blk_score_n = '1') then -- send block color data
            -- prev_game_data <= cur_game_data;
            cur_game_data <= BLOCK_ARR(to_integer(y))(to_integer(x));
          -- elsif (game_blk_score_n = '0') then -- send score data
            -- cur_game_data <= num(x)(y);
          else
            cur_game_data <= (others => '0');
          end if;
        else 
          cur_game_data <= (others => '0');
        end if;
      end if;
    end if;

  end process;

end architecture behavioral;