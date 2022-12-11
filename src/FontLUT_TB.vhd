library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FontLUT_TB is
end entity FontLUT_TB;


architecture behavioral of FontLUT_TB is

    constant CLK_PERIOD : time := 100 ns;

    component FontLUT is
        port (
            en      : in std_logic;
            sel     : in unsigned(3 downto 0);
            xaddr   : in unsigned(2 downto 0);
            yaddr   : in unsigned(3 downto 0);
            px      : out std_logic
        );
    end component FontLUT;

    signal clk      : std_logic;

    signal en        : std_logic;
    signal sel_vec   : unsigned(3 downto 0);
    signal xaddr_vec : unsigned(2 downto 0);
    signal yaddr_vec : unsigned(3 downto 0);
    signal sel, xaddr, yaddr : natural;

    signal px       : std_logic;

begin

    sel_vec   <= to_unsigned(sel, 4);
    xaddr_vec <= to_unsigned(xaddr, 3);
    yaddr_vec <= to_unsigned(yaddr, 4);

    uut : FontLUT
        port map (
            en    => en,
            sel   => sel_vec,
            xaddr => xaddr_vec,
            yaddr => yaddr_vec,
            px    => px
        );

    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process; -- clk_proc

    stim_proc : process
    begin

        en      <= '1';
        sel     <= 0;
        xaddr   <= 0;
        yaddr   <= 0;

        sel   <= 1;
        yaddr <= 15;
        one_row_15 : for i in 0 to 7
        loop
            xaddr <= i;
            wait for CLK_PERIOD;
        end loop one_row_15;

        en <= '0';
        wait for 2 * CLK_PERIOD;
        en <= '1';
        
        yaddr <= 0;
        sel_loop : for i in 0 to 9
        loop
            sel <= i;
            col_loop : for j in 0 to 7
            loop
                xaddr <= j;
                wait for CLK_PERIOD;
            end loop col_loop;
            en <='0';
            wait for 2 * CLK_PERIOD;
            en <= '1';
        end loop sel_loop;

    end process; -- stim_proc

end architecture behavioral;
