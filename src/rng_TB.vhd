library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng_TB is
end entity rng_TB;

architecture behavioral of rng_TB is

    constant CLK_PERIOD : time := 100 ns;

	component rng is
		port (
			clk : in std_logic;
      rst_n : in std_logic;
      rng_en : in std_logic;
      rng_q  : out std_logic_vector(7 downto 0)
		);
	end component rng;
	
	signal clk, rst_n, rng_en : std_logic;
  signal rng_q : std_logic_vector(7 downto 0);
	
begin -- behavioral of rng_TB
	
	uut : rng
		port map (
      clk => clk,
      rst_n => rst_n,
      rng_en => rng_en,
      rng_q => rng_q
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

        -- Initial
        rst_n <= '1';
        rng_en <= '0';

        -- Reset
    wait for CLK_PERIOD*5;
    rng_en <= '1';
		wait for CLK_PERIOD*5;
		rst_n <= '0';
		wait for CLK_PERIOD*5;
		rng_en <= '0';
		wait for CLK_PERIOD*5;
    rst_n <= '1';
		for i in 1 to 256 loop
		wait for CLK_PERIOD;
		rng_en <= not rng_en;
		end loop;
    -- End
    wait;

    end process; -- stim_process

end architecture behavioral; -- rng_TB