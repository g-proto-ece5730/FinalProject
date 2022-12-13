library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GameEngine is
  port (
    clk   : in std_logic;
    rst_n : in std_logic;
    VS     : in std_logic;

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
  signal BLOCK_ARR : BLOCK_ARR_T := (others => (others => x"0")); -- Initialize to zeros???
  -- := (
  --   (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- first row
  --   (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- second row
  --   (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- third row
  --   (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1"), -- fourth row
  --   (x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2"), -- fifth row
  --   (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- 6th row
  --   (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- 7th row
  --   (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- 8th row
  --   (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1"), -- 9th row
  --   (x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2"), -- 10th row
  --   (x"0",x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3"), -- 11th row
  --   (x"1",x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4"), -- 12th row
  --   (x"2",x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0"), -- 13th row
  --   (x"3",x"4",x"0",x"1",x"2",x"3",x"4",x"0",x"1") -- 14th row
  -- );

  type STACK_COUNTER_T is array(0 to 8) of natural;
  signal stack_counter : STACK_COUNTER_T := (others => 0);

  type PHASE_TYPE is (IDLE, DESCEND, STOP, CHECK);
  signal phase : PHASE_TYPE;

  signal d_block_y, d_block_x, prev_d_block_x, prev_d_block_y : natural; 
  signal d_block_color : std_logic_vector(3 downto 0);
  signal descend_counter : unsigned(32 downto 0);
  signal blocks_fell, search_en, search_fin, start : std_logic;
  
  -- type BUFFER_ARR_T is array(0 to 2) of std_logic_vector(3 downto 0);
  -- signal BUFFER_ARR : BUFFER_ARR_T;

  constant DESCEND_RATE : integer := 1; -- for simulation
  -- constant DESCEND_RATE : integer := 25_000_000;

begin

  game_data <= cur_game_data;
  x <= game_hpos;
  y <= game_vpos;
  start <= start_btn;
  -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;

  search_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        search_fin <= '0';
        blocks_fell <= '1';
        stack_counter <= (others => 0);
      else
        if (search_en = '1') then
          stack_counter(4) <= stack_counter(4) + 1;
          if (prev_d_block_x - 1 > 0 AND prev_d_block_x - 2 > 0) then
            -- check for 3 in a row to the left of the placed block
            if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1)) then
              if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 2)) then
                -- clear 3 blocks
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 2) <= x"0";
                -- decrement column stack counter
                stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) - 1;
                stack_counter(prev_d_block_x - 1) <= stack_counter(prev_d_block_x - 1) - 1;
                stack_counter(prev_d_block_x - 2) <= stack_counter(prev_d_block_x - 2) - 1;
                -- check in columns above cleared blocks and drop blocks down
                if (stack_counter(prev_d_block_x) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x - 1) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x - 1)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x - 1) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x - 1);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x - 2) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x - 2)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x - 2) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 2) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x - 2);
                    end if;
                  end loop;
                end if;
              end if;
            end if;
          end if;

          -- -- check for 3 in a row above the placed block ; we shouldn't need to check above the descending block, right?
          -- if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x)) then
          --   if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y - 2)(prev_d_block_x)) then
          --     BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= x"0";
          --     BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x) <= x"0";
          --     BLOCK_ARR(prev_d_block_y - 2)(prev_d_block_x) <= x"0";
          --     stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) - 3;
          --   end if;
          -- end if;

          if (prev_d_block_x + 1 < 9 AND prev_d_block_x + 2 > 9) then
            -- check for 3 in a row to the right of the placed block
            if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1)) then
              if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 2)) then
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 2) <= x"0";
                stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) - 1;
                stack_counter(prev_d_block_x + 1) <= stack_counter(prev_d_block_x + 1) - 1;
                stack_counter(prev_d_block_x + 2) <= stack_counter(prev_d_block_x + 2) - 1;
                -- check in columns above cleared blocks and drop blocks down
                if (stack_counter(prev_d_block_x) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x + 1) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x + 1)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x + 1) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x + 1);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x + 2) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x + 2)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x + 2) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 2) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x + 2);
                    end if;
                  end loop;
                end if;
              end if;
            end if;
          end if;

          if (prev_d_block_y + 1 < 14) then
            -- check for 3 in a row below the placed block
            if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y + 1)(prev_d_block_x)) then
              if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y + 2)(prev_d_block_x)) then
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= x"0";
                BLOCK_ARR(prev_d_block_y + 1)(prev_d_block_x) <= x"0";
                BLOCK_ARR(prev_d_block_y + 2)(prev_d_block_x) <= x"0";
                stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) - 3;
              end if;
            end if;
          end if;

          if (prev_d_block_x - 1 > 0 AND prev_d_block_x + 1 < 9) then
            -- check for 3 in a row on both sides of block
            if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1)) then
              if (BLOCK_ARR(prev_d_block_y)(prev_d_block_x) = BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1)) then
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1) <= x"0";
                BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1) <= x"0";
                stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) - 1;
                stack_counter(prev_d_block_x - 1) <= stack_counter(prev_d_block_x - 1) - 1;
                stack_counter(prev_d_block_x + 1) <= stack_counter(prev_d_block_x + 1) - 1;
                -- check in columns above cleared blocks and drop blocks down
                if (stack_counter(prev_d_block_x) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x - 1) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x - 1)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x - 1) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x - 1) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x - 1);
                    end if;
                  end loop;
                end if;
                if (stack_counter(prev_d_block_x + 1) > 0) then
                  for i in 13 to (13-stack_counter(prev_d_block_x + 1)) loop
                    if (BLOCK_ARR(i - 1)(prev_d_block_x + 1) /= x"0") then
                      BLOCK_ARR(prev_d_block_y)(prev_d_block_x + 1) <= BLOCK_ARR(prev_d_block_y - 1)(prev_d_block_x + 1);
                    end if;
                  end loop;
                end if;
              end if;
            end if;
          end if;
            search_fin <= '1';
          else
            search_fin <= '0';
        end if;

      end if; -- rst_n = '0'
    end if; -- rising_edge(clk)
  end process; -- search_proc


  phase_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        phase <= IDLE;
        descend_counter <= (others => '0');
        d_block_x <= 4;
        d_block_y <= 0;
        prev_d_block_x <= d_block_x;
        prev_d_block_y <= d_block_y;
        d_block_color <= x"1";
        -- stack_counter <= (others => 0);
      else
        case phase is

          when IDLE =>
            if (start = '1') then
              phase <= DESCEND;
              descend_counter <= (others => '0');
              d_block_x <= 4;
              d_block_y <= 0;
              prev_d_block_x <= d_block_x;
              prev_d_block_y <= d_block_y;
              d_block_color <= x"1";
              -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
            else
              phase <= IDLE;
              descend_counter <= (others => '0');
              d_block_x <= 4;
              d_block_y <= 0;
              prev_d_block_x <= d_block_x;
              prev_d_block_y <= d_block_y;
              d_block_color <= x"1";
              -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
            end if;

          when DESCEND =>
            if (descend_counter = DESCEND_RATE) then
              descend_counter <= (others => '0');
              if (d_block_y < 13) then
                if (BLOCK_ARR(d_block_y + 1)(d_block_x) = x"0") then
                  -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
                  -- BLOCK_ARR(d_block_y - 1)(d_block_x) <= x"0";
                  phase <= DESCEND;
                  d_block_y <= d_block_y + 1;
                  prev_d_block_x <= d_block_x;
                  prev_d_block_y <= d_block_y;
                  d_block_color <= x"1";
                  BLOCK_ARR(prev_d_block_y)(d_block_x) <= x"0";
                else
                  phase <= CHECK;
                  d_block_x <= 4;
                  d_block_y <= 0;
                  prev_d_block_x <= d_block_x;
                  prev_d_block_y <= d_block_y;
                  d_block_color <= x"0";
                  -- stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) + 1;
                  BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
                  -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
                end if;
                else
                  phase <= CHECK;
                  d_block_x <= 4;
                  d_block_y <= 0;
                  prev_d_block_x <= d_block_x;
                  prev_d_block_y <= d_block_y;
                  d_block_color <= x"0";
                  -- stack_counter(prev_d_block_x) <= stack_counter(prev_d_block_x) + 1;
                  BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
                  -- BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;
              end if;
            else
              descend_counter <= descend_counter + "1";
            end if;

          -- when STOP =>

          when CHECK =>
            search_en <= '1';
            if (search_fin = '0') then
              phase <= CHECK;
              search_en <= '1';
            else
              phase <= DESCEND;
              search_en <= '0';
            end if;

          when others =>
            phase <= IDLE;
            descend_counter <= (others => '0');
            d_block_x <= 4;
            d_block_y <= 0;
            d_block_color <= x"1";
            BLOCK_ARR(d_block_y)(d_block_x) <= d_block_color;

        end case; -- phase
      end if; -- rst_n = '0'
    end if; -- rising_edge(clk)


  end process; -- phase_proc


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
  end process; -- main_proc

end architecture behavioral;