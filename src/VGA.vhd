library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is
    port (
        rst_n : in std_logic;
        pxclk : in std_logic;
        xaddr : out unsigned(9 downto 0);
        yaddr : out unsigned(8 downto 0);
        addr_valid : out std_logic;
        HS : out std_logic;
        VS : out std_logic
    );
end entity VGA;

architecture behavioral of VGA is

    constant H_PIXELS : integer := 640;
    constant V_PIXELS : integer := 480;

	constant H_SYNC_PULSE : integer     := 96;
	constant H_BACK_PORCH : integer		:= 48;
    constant H_FRONT_PORCH : integer    := 16;

	constant V_SYNC_PULSE : integer     := 2;
    constant V_BACK_PORCH : integer		:= 33;
    constant V_FRONT_PORCH : integer    := 10;

	type state_type is (BACK_PORCH, SYNC, VISIBLE, FRONT_PORCH);
	signal h_state, v_state : state_type;
    
    signal x : unsigned(9 downto 0);
    signal y : unsigned(8 downto 0);
    signal h_sync, v_sync, new_line : std_logic;

begin

	xaddr <= x;
	yaddr <= y;
	HS    <= not h_sync;
	VS    <= not v_sync;
	addr_valid <= '1' when (h_state = VISIBLE) and (v_state = VISIBLE) else '0';

    h_process : process(px_clk)
    begin
        if rising_edge(px_clk) then
            if (rst_n = '0') then
                x <= (others => '0');
				new_line <= '0';
				h_sync <= '0';
				h_state <= FRONT_PORCH;
            else
                case h_state is

					when SYNC =>
						new_line <= '0';
						if x < H_SYNC_PULSE-1 then
							x <= x + 1;
						else
							x <= (others => '0');
							h_sync <= '0';
							h_state <= BACK_PORCH;
						end if;

					when BACK_PORCH =>
						if x < H_BACK_PORCH-1 then
							x <= x + 1;
						else
							x <= (others => '0');
							h_state <= VISIBLE;
						end if;

					when VISIBLE =>
						if x < H_PIXELS-1 then
							x <= x + 1;
						else
							x <= (others => '0');
							h_state <= FRONT_PORCH;
						end if;

					when FRONT_PORCH =>
						if x < H_FRONT_PORCH-1 then
							x <= x + 1;
						else
							x <= (others => '0');
							new_line <= '1';
							h_sync  <= '1';
							h_state <= SYNC;
						end if;

					when others =>
						x <= (others => '0');
						new_line <= '0';
						h_sync <= '0';
						h_state <= FRONT_PORCH;

				end case;
            end if;
        end if;
    end process; -- h_process

	v_process : process(px_clk)
	begin
		if rising_edge(px_clk) then
            if (rst_n = '0') then
                y <= (others => '0');
				v_sync <= '0';
				v_state <= FRONT_PORCH;
            elsif (new_line = '1') then
				case v_state is

					when SYNC =>
						if y < V_SYNC_PULSE-1 then
							y <= y + 1;
						else
							y <= (others => '0');
							v_sync <= '0';
							v_state <= BACK_PORCH;
						end if;

					when BACK_PORCH =>
							if y < V_BACK_PORCH-1 then
								y <= y + 1;
							else
								y <= (others => '0');
								v_state <= VISIBLE;
							end if;

					when VISIBLE =>
						if y < V_PIXELS-1 then
							y <= y + 1;
						else
							y <= (others => '0');
							v_state <= FRONT_PORCH;
						end if;

					when FRONT_PORCH =>
						if y < V_FRONT_PORCH-1 then
							y <= y + 1;
						else
							y <= (others => '0');
							v_sync <= '1';
							v_state <= SYNC;
						end if;

					when others =>
						y <= (others => '0');
						v_sync <= '0';
						v_state <= FRONT_PORCH;

				end case;
            end if;
        end if;
	end process; -- v-process
    
end architecture behavioral;
