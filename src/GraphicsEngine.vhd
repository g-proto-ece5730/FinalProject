library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity GraphicsEngine is
    port (
        pxclk : in std_logic;
        rst_n : in std_logic;

        -- Game Engine port group
        game_en          : out std_logic;
        game_blk_score_n : out std_logic;
        game_hpos        : out std_logic_vector(3 downto 0);
        game_vpos        : out std_logic_vector(3 downto 0);
        game_data        : in std_logic_vector(3 downto 0);

        -- VGA port group
        vga_x     : in std_logic_vector(9 downto 0);
        vga_y     : in std_logic_vector(8 downto 0);
        vga_valid : in std_logic;
        vga_rgb   : out std_logic;
    );
end entity GraphicsEngine;


architecture behavioral of GraphicsEngine is

    --------------------------------------------------
    -- BEGIN: COMPONENTS
    --------------------------------------------------
    component ColorLUT is
        port (
            en  : std_logic;
            sel : std_logic_vector(2 downto 0);
            rgb : std_logic_vector(23 downto 0)
        );
    end component ColorLUT;
    signal color_en  : std_logic;
    signal color_sel : std_logic_vector(2 downto 0);
    signal color_rgb : std_logic_vector(23 downto 0);

    component BlockFIFO is
        port (
            clock   : in std_logic;
            sclr    : in std_logic;
            wreq    : in std_logic;
            data    : in std_logic_vector (23 downto 0);
            rdreq   : in std_logic;
            q       : out std_logic_vector(23 downto 0)
        );
    end component BlockFIFO;
    signal bfifo_wreq : std_logic;
    signal bfifo_din  : std_logic_vector(23 downto 0);
    signal bfifo_rack : std_logic;
    signal bfifo_dout : std_logic_vector(23 downto 0);


    component FontLUT is
        port (
            en      : in std_logic;
            sel     : in unsigned(3 downto 0);
            xaddr   : in unsigned(2 downto 0);
            yaddr   : in unsigned(3 downto 0);
            px      : out std_logic
        );
    end component FontLUT;
    signal font_en  : std_logic;
    signal font_sel : unsigned(3 downto 0);
    signal font_x   : unsigned(2 downto 0);
    signal font_y   : unsigned(3 downto 0);
    signal font_px  : std_logic;

    component FontFIFO is
        port (
            clock   : in std_logic;
            sclr    : in std_logic;
            wreq    : in std_logic;
            data    : in std_logic_vector(0 downto 0);
            rdreq   : in std_logic;
            q       : out std_logic_vector(0 downto 0)
        );
    end component FontFIFO;
    signal ffifo_wreq : std_logic;
    signal ffifo_din  : std_logic_vector(0 downto 0);
    signal ffifo_rack : std_logic;
    signal ffifo_dout : std_logic_vector(0 downto 0);
    --------------------------------------------------
    -- END: COMPONENTS
    --------------------------------------------------
    

    --------------------------------------------------
    -- BEGIN: CONSTANTS
    --------------------------------------------------
    constant BLOCK_W    : natural := 32;
    constant BLOCK_H    : natural := 32;
    constant GRID_W     : natural := 9;
    constant GRID_H     : natural := 14;
    constant GRID_X     : natural := 177;
    constant GRID_Y     : natural := 17
    constant GRID_X2    : natural := GRID_X + GRID_W;
    constant GRID_Y2    : natural := GRIX_Y + GRIX_H;

    constant BORDER_W   : natural := 290;
    constant BORDER_H   : natural := 450;
    constant BORDER_X   : natural := GRID_X - 1;
    constant BORDER_Y   : natural := GRID_Y - 1;
    constant BORDER_X2  : nautral := BORDER_X + BORDER_W;
    constant BORDER_Y2  : natural := BORDER_Y + BORDER_H;

    constant FONT_W     : natural := 8;
    constant FONT_H     : natural := 16;
    constant FONT_SCALE : natural := 3;
    constant SCORE_W    : natural := 6;
    constant SCORE_X    : natural := 480;
    constant SCORE_Y    : natural := 320;
    constant SCORE_X2   : natural := SCORE_X + (SCORE_W * FONT_SCALE * FONT_W);
    constant SCORE_Y2   : natural := SCORE_Y + (FONT_SCALE * FONT_H);
    --------------------------------------------------
    -- END: CONSTANTS
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: ALIASES & WIRES
    --------------------------------------------------
    signal is_blk_row   : std_logic;
    signal is_score_row : std_logic;
    --------------------------------------------------
    -- END: ALIASES & WIRES
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: STATE MACHINES
    --------------------------------------------------
    -- Prefetch FSM
    type PREFETCH_STATE_T is (
        IDLE,
        FETCH_BLOCKS,
        FETCH_SCORE
    );
    signal prefetch_state       : PREFETCH_STATE_T;
    signal prefetch_blk_y       : natural range 0 to BLOCK_H-1;
    signal prefetch_font_y      : natural range 0 to FONT_H-1;
    signal prefetch_font_vscale : natural range 0 to FONT_SCALE-1;

    -- Draw FSM
    type DRAW_STATE_T is (
        IDLE,
        PREFETCH,
        DRAW
    );
    signal lookup_state : LOOKUP_STATE_T;
    --------------------------------------------------
    -- END: STATE MACHINES
    --------------------------------------------------

begin

    --------------------------------------------------
    -- BEGIN: INSTANTIATIONS
    --------------------------------------------------
    ColorLUT_0 : ColorLUT
        port map (
            en  => color_en,
            sel => color_sel,
            rgb => color_rgb
        );

    BlockFIFO_0 : BlockFIFO 
        port map (
            clock   => pxclk,
            sclr    => rst,
            wreq    => bfifo_wreq,
            data    => bfifo_din,
            rdreq   => bfifo_rack,
            q       => bfifo_dout
        );

    FontLUT_0 : FontLUT
        port map (
            en    => font_en,
            sel   => font_sel,
            xaddr => font_x,
            yaddr => font_y,
            px    => font_px
        );

    FontFIFO_0 : FontFIFO
        port map (
            clock   => pxclk,
            sclr    => rst,
            wreq    => ffifo_wreq,
            data    => ffifo_din,
            rdreq   => ffifo_rack,
            q       => ffifo_dout
        );
    --------------------------------------------------
    -- END: INSTANTIATIONS
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: WIRING
    --------------------------------------------------
    is_blk_row   <= (to_integer(vga_y) >= GRID_Y) and (to_integer(vga_y) <= GRID_Y2);
    is_score_row <= (to_integer(vga_y) >= SCORE_Y) and (to_integer(vga_y) <= SCORE_Y2);
    --------------------------------------------------
    -- END: WIRING
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: PREFETCH FSM
    --------------------------------------------------
    color_sel <= game_data;
    font_sel  <= game_data;
    bfifo_din <= color_rgb;
    ffifo_din <= font_px;
    prefetch_proc : process (pxclk)
    begin
        if rising_edge(pxclk) then
            if (rst_n = '0') then
                game_en         <= '0';
                color_en        <= '0';
                font_en         <= '0';
                bfifo_wreq      <= '0';
                ffifo_wreq      <= '0';
                prefetch_state  <= IDLE;
            else
                case prefetch_state is

                    when IDLE =>
                        if (vga_valid = '1') and (vga_x = (others => '0')) and (is_blk_row = '1') then
                            prefetch_state      <= FETCH_BLOCKS;
                            game_en             <= '1';
                            game_block_score_n  <= '1';
                            game_hpos           <= (others => '0');
                            color_en            <= '1';
                            bfifo_wreq          <= '1';
                            if (to_integer(vga_y) = GRID_Y) then
                                game_vpos       <= (others => '0');
                                prefetch_blk_y  <= 0;
                            else
                                if (prefetch_blk_y < BLOCK_H-1) then
                                    prefetch_blk_y <= prefetch_blk_y + 1;
                                else
                                    game_vpos       <= game_vpos + '1';
                                    prefetch_blk_y  <= 0;
                                end if;
                            end if;
                        end if;

                    when FETCH_BLOCKS =>
                        if (to_integer(game_hpos) < BLOCK_W-1) then
                            game_hpos <= game_hpos + '1';
                        else
                            color_en   <= '0';
                            bfifo_wreq <= '0';
                            if (is_score_row = '1') then
                                prefetch_state      <= FETCH_SCORE
                                game_block_score _n <= '0';
                                game_hpos           <= (others => '0');
                                font_en             <= '1';
                                font_x              <= (others => '0');
                                ffifo_wreq          <= '1';
                                if (to_integer(vga_y) = SCORE_X) then
                                    font_y               <= (others => '0');
                                    prefetch_font_vscale <= 0;
                                else
                                    if (prefetch_font_vscale >= FONT_SCALE-1) then
                                        font_y               <= font_y + '1';
                                        prefetch_font_vscale <= 0;
                                    else
                                        prefetch_font_vscale <= prefetch_font_vscale + 1;
                                    end if;
                                end if;
                            else
                                prefetch_state <= IDLE;
                                game_en        <= '0';
                            end if;
                        end if;

                    when FETCH_SCORE =>
                        if (to_integer(font_x) < FONT_W-1) then
                            game_en   <= '0';
                            font_x    <= font_x + 1;
                        else
                            if (to_integer(game_hpos) < SCORE_W-1) then
                                game_en   <= '1';
                                game_hpos <= game_hpos + '1';
                                font_x    <= (others => '0');
                            else
                                prefetch_state  <= IDLE;
                                game_en         <= '0';
                                font_en         <= '0';
                                ffifo_wreq      <= '0';
                        end if;

                    when others =>
                        game_en         <= '0';
                        color_en        <= '0';
                        font_en         <= '0';
                        bfifo_wreq      <= '0';
                        ffifo_wreq      <= '0';
                        prefetch_state  <= IDLE;

                end case;
            end if; -- (rst_n = '0')
        end if; -- rising_edge(pxclk)
    end process; -- prefetch_proc
    --------------------------------------------------
    -- END: PREFETCH FSM
    --------------------------------------------------

end architecture behavioral;
