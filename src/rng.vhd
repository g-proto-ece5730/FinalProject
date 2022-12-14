library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        rng_en : in std_logic;
        rng_q  : out std_logic_vector(7 downto 0)
    );
end entity rng;


architecture behavioral of rng is
	 
    constant SEED : std_logic_vector(11 downto 0) := x"5A7"; -- 0101 1010 1110

    signal start, start_prev : std_logic;
    signal feedback_bit : std_logic := '1';
    signal lfsr : std_logic_vector(11 downto 0) := SEED;

    signal rand : std_logic_vector(7 downto 0);

    signal q : std_logic_vector(3 downto 0);

begin

    start <= rng_en;

    process (clk)
    begin
        if rising_edge(clk) then
            start_prev <= start;

            if rst_n = '0' then
                -- Reset logic
                lfsr <= SEED;
                q <= x"0";
                feedback_bit <= '1';
            elsif start = '1' and start_prev = '0' then
                feedback_bit <= lfsr(11) xor lfsr(9) xor lfsr(7) xor lfsr(3) xor '1';
                lfsr <= feedback_bit & lfsr(11 downto 1);
            end if;
        end if;
    end process;

    rand <= lfsr(2) & lfsr(0) & lfsr(5) & lfsr(6) & lfsr(10) & lfsr(1) & lfsr(4) & lfsr(8);
    rng_q <= rand;

end architecture behavioral;
