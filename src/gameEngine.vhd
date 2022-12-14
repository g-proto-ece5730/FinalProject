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

    -- Audio Engine port group
    aud_en  : out std_logic;
    aud_sel : out std_logic_vector(3 downto 0);

    -- Controls port group
    start_btn   : in std_logic;
    dir_control : in std_logic_vector(11 downto 0)
  );
end entity GameEngine;

architecture behavioral of GameEngine is

  -- testing RNG
  component rng is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        rng_en : in std_logic;
        rng_q  : out std_logic_vector(7 downto 0)
    );
  end component;

  signal x, y : unsigned(3 downto 0);
  -- 0 black
  -- 1 red
  -- 2 green
  -- 3 blue
  -- 4 yellow
  type BLOCK_ROW_T is array(0 to 8) of std_logic_vector(3 downto 0);
  type BLOCK_ARR_T is array(0 to 13) of BLOCK_ROW_T;
  signal BLOCK_ARR : BLOCK_ARR_T := (others => (others => x"0"));
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

  signal start, game_over, cleared : std_logic;
  signal floating_blocks : std_logic;

  signal rng_en : std_logic;
  signal rng_color : std_logic_vector(7 downto 0);

  signal dir : std_logic_vector(11 downto 8);
  signal lane : natural;

  type SCORE_ARR is array(0 to 5) of std_logic_vector(3 downto 0);
  signal score_data : SCORE_ARR := (others => x"0");
  signal score : unsigned(23 downto 0) := (others => '0');
  signal add_points : unsigned(7 downto 0);

  signal descend_counter : natural;
  constant DESCEND_RATE : integer := 1; -- for simulation
  -- constant DESCEND_RATE : integer := 25_000_000;

begin

  -- testing RNG
  color_generator : rng 
    port map (
        clk     => clk,
        rst_n   => rst_n,
        rng_en  => rng_en,
        rng_q   => rng_color
    );

  x <= game_hpos;
  y <= game_vpos;
  start <= not start_btn;
  dir <= dir_control(11 downto 8);
  -- rng_color <= rng_q;

  game_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        game_over <= '1';
        floating_blocks <= '0';
        cleared <= '0';
        BLOCK_ARR <= (others => (others => x"0"));
        rng_en <= '0';
        descend_counter <= 0;
        add_points <= (others => '0');
      else
        if (start = '1') then 
          game_over <= '0';
        end if;

        if (descend_counter = DESCEND_RATE) then
          rng_en <= '0';
          descend_counter <= 0;
          if (game_over = '0') then
            floating_blocks <= '0';
            for j in 0 to 12 loop
              for i in 0 to 8 loop
                -- main descending block 
                if (BLOCK_ARR(j)(i)(3) = '1') then 
                  -- BLOCK_ARR(j)(lane) <= BLOCK_ARR(j)(i);
                  -- BLOCK_ARR(j+1)(i) <= x"0";
                  if (BLOCK_ARR(j+1)(lane) /= x"0") then -- main block landed on another block
                    BLOCK_ARR(j)(lane) <= "0" & BLOCK_ARR(j)(i)(2 downto 0);
                  elsif (j >= 12) then  -- main block landed on bottom
                    BLOCK_ARR(j+1)(lane) <= "0" & BLOCK_ARR(j)(i)(2 downto 0);
                    BLOCK_ARR(j)(i) <= x"0";
                  else
                    BLOCK_ARR(j+1)(lane) <= BLOCK_ARR(j)(i);
                    BLOCK_ARR(j)(i) <= x"0";
                    floating_blocks <= '1';
                  end if;
                -- end if;

                -- search for other floating blocks and drop them
                elsif (BLOCK_ARR(j)(i) /= x"0" AND BLOCK_ARR(j+1)(i) = x"0") then
                  BLOCK_ARR(j+1)(i) <= BLOCK_ARR(j)(i);
                  BLOCK_ARR(j)(i) <= x"0";
                  floating_blocks <= '1';
                end if;
              end loop;
            end loop;

            if (floating_blocks = '0') then
              -- search for and clear horizontal rows of 3
              cleared <= '0';
              for j in 13 downto 0 loop
                for i in 0 to 6 loop
                  if (BLOCK_ARR(j)(i) /= x"0") then
                    if (BLOCK_ARR(j)(i) = BLOCK_ARR(j)(i+1) AND BLOCK_ARR(j)(i) = BLOCK_ARR(j)(i+2)) then
                      BLOCK_ARR(j)(i) <= x"0";
                      BLOCK_ARR(j)(i+1) <= x"0";
                      BLOCK_ARR(j)(i+2) <= x"0";
                      cleared <= '1';
                      add_points <= add_points + 3;
                    end if;
                  end if;
                end loop; 
              end loop;

              -- search for and clear vertical rows of 3
              for i in 0 to 8 loop
                for j in 13 downto 2 loop
                  if (BLOCK_ARR(j)(i) /= x"0") then
                    if (BLOCK_ARR(j)(i) = BLOCK_ARR(j-1)(i) AND BLOCK_ARR(j)(i) = BLOCK_ARR(j-2)(i)) then
                      BLOCK_ARR(j)(i) <= x"0";
                      BLOCK_ARR(j-1)(i) <= x"0";
                      BLOCK_ARR(j-2)(i) <= x"0";
                      cleared <= '1';
                      add_points <= add_points + 3;
                    end if;
                  end if;
                end loop; 
              end loop;
            end if;

            -- game over or request new block color from rng
            if (cleared = '0' and floating_blocks = '0') then

              if (BLOCK_ARR(1) /= (x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0")) then 
                game_over <= '1';
              else
                rng_en <= '1';
                floating_blocks <= '1';
              end if;
            end if;
          end if; -- game_over
        else
          descend_counter <= descend_counter + 1;
        end if;

        -- request block color from rng until we get a valid number between 1 and 4
        if (rng_en = '1') then
          if (rng_color(3 downto 0) > x"0" and rng_color(3 downto 0) < x"5") then
            BLOCK_ARR(0)(lane) <= '1' & rng_color(2 downto 0); -- BLOCK_ARR(0)(4) should eventually be BLOCK_ARR(0)(X) where X is the location from ADC
            floating_blocks <= '1';
            rng_en <= '0';
          end if;
        end if;

        if (add_points > x"0") then
          for i in 0 to 4 loop
            score_data(i) <= std_logic_vector(unsigned(score_data(i)) + 1);
            if score_data(i) >= x"9" then
              score_data(i) <= (others => '0');
              score_data(i+1) <= std_logic_vector(unsigned(score_data(i+1)) + 1);
            else
              exit;
            end if;
          end loop;
            add_points <= add_points - 1;
        end if;
        
        if (dir = x"0") then
          lane <= 0;
        elsif (dir = x"1") then
          lane <= 1;
        elsif (dir = x"2") then
          lane <= 2;
        elsif (dir = x"3") then
          lane <= 3;
        elsif (dir = x"4") then
          lane <= 4;
        elsif (dir = x"5") then
          lane <= 5;
        elsif (dir = x"6") then
          lane <= 6;
        elsif (dir = x"7") then
          lane <= 7;
        elsif (dir >= x"8") then
          lane <= 8;
        end if;

      end if; -- rst_n
    end if; -- rising_edge(clk)
  end process;


  gfx_proc : process(clk)
  begin
    if (rst_n = '0') then
      game_data <= (others => '0');
    else
      if (game_en = '1') then
        if (game_blk_score_n = '1') then -- send block color data
          case game_hpos is
            when x"0" => game_data <= block_arr(to_integer(game_vpos))(0);
            when x"1" => game_data <= block_arr(to_integer(game_vpos))(1);
            when x"2" => game_data <= block_arr(to_integer(game_vpos))(2);
            when x"3" => game_data <= block_arr(to_integer(game_vpos))(3);
            when x"4" => game_data <= block_arr(to_integer(game_vpos))(4);
            when x"5" => game_data <= block_arr(to_integer(game_vpos))(5);
            when x"6" => game_data <= block_arr(to_integer(game_vpos))(6);
            when x"7" => game_data <= block_arr(to_integer(game_vpos))(7);
            when x"8" => game_data <= block_arr(to_integer(game_vpos))(8);
            when others => game_data <= (others => '0');
          end case;
          -- data <= block_arr(to_integer(game_vpos))(to_integer(game_hpos)); -- Doesn't work, but above case statement does...?
        else
          game_data <= std_logic_vector(game_hpos);
        end if;
      else
        game_data <= (others => '0');
      end if;
    end if; -- (rst_n = '0')
  end process;

end architecture behavioral;