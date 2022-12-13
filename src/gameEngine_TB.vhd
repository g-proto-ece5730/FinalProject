library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GameEngine_TB is
end entity GameEngine_TB;

architecture behavioral of GameEngine_TB is 

  constant CLK_PERIOD : time := 100 ns;

  component GameEngine is
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
  end component;

  signal clk, rst_n, VS, game_en, game_blk_score_n, rng_en, aud_en, start : std_logic;
  signal game_hpos, game_vpos : unsigned(3 downto 0);
  signal game_data : std_logic_vector(3 downto 0);
  signal rng_q : std_logic_vector(7 downto 0);
  signal aud_sel : std_logic_vector(3 downto 0);
  signal dir_control : std_logic_vector(11 downto 0);

begin

  uut : gameEngine 
    port map (
      clk   => clk,
      rst_n => rst_n,
      VS => VS,
      game_en        => game_en,
      game_blk_score_n => game_blk_score_n,
      game_hpos         => game_hpos,
      game_vpos         => game_vpos,
      game_data      => game_data,
      rng_en => rng_en,
      rng_q  => rng_q,
      aud_en  => aud_en,
      aud_sel => aud_sel,
      start_btn   => start,
      dir_control => dir_control
    );

  clk_process : process
  begin
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
  end process; -- clk_process

  stim_process : process
  begin
    -- initial
    rst_n <= '0';
    game_en <= '0';
    game_blk_score_n <= '0';
    game_hpos <= (others => '0');
    game_vpos <= (others => '0');
    start <= '0';

    wait for CLK_PERIOD*2;
    rst_n <= '1';
    game_en <= '1';
    game_blk_score_n <= '1';
    start <= '1';
    wait for CLK_PERIOD*2;
    start <= '0';

    -- for i in 0 to 13 
    -- loop
    --   game_x <= (others => '0');
    --   game_y <= to_unsigned(i,game_y'length);
    --   for j in 0 to 8
    --   loop
    --     game_x <= to_unsigned(j,game_x'length);
    --   wait for CLK_PERIOD*2;
    --   end loop;
    -- end loop;

    wait for CLK_PERIOD*5_000_000;
    
  end process;

end architecture behavioral;