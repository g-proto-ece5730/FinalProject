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
        game_hpos        : out unsigned(3 downto 0);
        game_vpos        : out unsigned(3 downto 0);
        game_data        : in std_logic_vector(3 downto 0);

        -- VGA port group
        vga_x     : in unsigned(9 downto 0);
        vga_y     : in unsigned(8 downto 0);
        vga_valid : in std_logic;
        vga_rgb   : out std_logic_vector(23 downto 0)
    );
end entity GraphicsEngine;


architecture behavioral of GraphicsEngine is

    --------------------------------------------------
    -- BEGIN: COMPONENTS
    --------------------------------------------------
    component ColorLUT is
        port (
            en  : in std_logic;
            sel : in std_logic_vector(2 downto 0);
            rgb : out std_logic_vector(23 downto 0)
        );
    end component ColorLUT;
    signal color_en  : std_logic;
    signal color_sel : std_logic_vector(2 downto 0);
    signal color_rgb : std_logic_vector(23 downto 0);

    component BlockFIFO is
        port (
            clock   : in std_logic;
            sclr    : in std_logic;
            wrreq   : in std_logic;
            data    : in std_logic_vector (23 downto 0);
            rdreq   : in std_logic;
            q       : out std_logic_vector(23 downto 0);
            full    : out std_logic;
            empty   : out std_logic
        );
    end component BlockFIFO;
    signal bfifo_wreq : std_logic;
    signal bfifo_din  : std_logic_vector(23 downto 0);
    signal bfifo_rack : std_logic;
    signal bfifo_dout : std_logic_vector(23 downto 0);
    signal bfifo_full : std_logic;
    signal bfifo_empty: std_logic;


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
            wrreq   : in std_logic;
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
    constant GRID_Y     : natural := 17;
    constant GRID_X2    : natural := GRID_X + (BLOCK_W * GRID_W) - 1;
    constant GRID_Y2    : natural := GRID_Y + (BLOCK_H * GRID_H) - 1;

    constant BORDER_X   : natural := GRID_X - 1;
    constant BORDER_Y   : natural := GRID_Y - 1;
    constant BORDER_X2  : natural := GRID_X2 + 1;
    constant BORDER_Y2  : natural := GRID_Y2 + 1;

    constant FONT_W     : natural := 8;
    constant FONT_H     : natural := 16;
    constant FONT_SCALE : natural := 3;
    constant SCORE_W    : natural := 6;
    constant SCORE_X    : natural := 480;
    constant SCORE_Y    : natural := 320;
    constant SCORE_X2   : natural := SCORE_X + (FONT_SCALE * FONT_W * SCORE_W) - 1;
    constant SCORE_Y2   : natural := SCORE_Y + (FONT_SCALE * FONT_H) - 1;
    --------------------------------------------------
    -- END: CONSTANTS
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: INTERNAL SIGNALS
    --------------------------------------------------
    signal rst             : std_logic;
    signal is_blk_y        : std_logic;
    signal is_score_y      : std_logic;
    signal is_border_b_y   : std_logic;
    signal is_pre_grid_x   : std_logic;
    signal is_post_grid_x  : std_logic;
    signal is_post_grid_x2 : std_logic;
    signal is_pre_score_x  : std_logic;
    signal is_pre_score_x2 : std_logic;
    signal is_post_score_x : std_logic;
    signal is_post_score_x2: std_logic;
    --------------------------------------------------
    -- END: INTERNAL SIGNALS
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: STATE MACHINES
    --------------------------------------------------
    -- Prefetch FSM
    type PREFETCH_STATE_T is (
        PREFETCH_IDLE,
        FETCH_BLOCKS,
        FETCH_SCORE
    );
    signal prefetch_state       : PREFETCH_STATE_T;
    signal prefetch_hpos        : natural range 0 to GRID_W-1;
    signal prefetch_vpos        : natural range 0 to GRID_H-1;
    signal prefetch_blk_y       : natural range 0 to BLOCK_H-1;
    signal prefetch_font_y      : natural range 0 to FONT_H-1;
    signal prefetch_font_vscale : natural range 0 to FONT_SCALE-1;

    -- Draw FSM
    type DRAW_STATE_T is (
        DRAW_IDLE,
        DRAW_BORDER_L,
        DRAW_BLOCKS,
        DRAW_BORDER_R,
        DRAW_SCORE,
        DRAW_BORDER_B
    );
    signal draw_state  : DRAW_STATE_T;
    signal draw_blk_x  : natural range 0 to BLOCK_W-1;
    signal draw_hscale : natural range 0 to FONT_SCALE-1;
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
            wrreq   => bfifo_wreq,
            data    => bfifo_din,
            rdreq   => bfifo_rack,
            q       => bfifo_dout,
            full    => bfifo_full,
            empty   => bfifo_empty
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
            wrreq   => ffifo_wreq,
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
    rst             <= not rst_n;
    is_blk_y        <= '1' when (vga_valid = '1') and (to_integer(vga_y) >= GRID_Y) and (to_integer(vga_y) <= GRID_Y2) else '0';
    is_score_y      <= '1' when (vga_valid = '1') and (to_integer(vga_y) >= SCORE_Y) and (to_integer(vga_y) <= SCORE_Y2) else '0';
    is_border_b_y   <= '1' when (vga_valid = '1') and (to_integer(vga_y) = BORDER_Y2) else '0';
    is_pre_grid_x   <= '1' when (vga_valid = '1') and (to_integer(vga_x) = GRID_X - 2) else '0';
    is_post_grid_x  <= '1' when (vga_valid = '1') and (to_integer(vga_x) = GRID_X2 - 1) else '0';
    is_post_grid_x2 <= '1' when (vga_valid = '1') and (to_integer(vga_x) = GRID_X2) else '0';
    is_pre_score_x  <= '1' when (vga_valid = '1') and (to_integer(vga_x) = SCORE_X - 2) else '0';
    is_pre_score_x2 <= '1' when (vga_valid = '1') and (to_integer(vga_x) = SCORE_X - 1) else '0';
    is_post_score_x <= '1' when (vga_valid = '1') and (to_integer(vga_x) = SCORE_X2 - 2) else '0';
    is_post_score_x2<= '1' when (vga_valid = '1') and (to_integer(vga_x) = SCORE_X2 - 1) else '0';
    -- END: WIRING
    --------------------------------------------------

    --------------------------------------------------
    -- BEGIN: PREFETCH FSM
    --------------------------------------------------
    -- process (all)
    -- begin
    --     case prefetch_hpos is
    --         when 2 => font_sel <= x"0";
    --         when others => font_sel <= x"9";
    --     end case;
    -- end process;
    game_hpos    <= to_unsigned(prefetch_hpos, game_hpos'length);
    game_vpos    <= to_unsigned(prefetch_vpos, game_vpos'length);
    color_sel    <= game_data(2 downto 0);
    --font_sel     <= unsigned(game_data);
    font_sel <= x"0";
    bfifo_din    <= color_rgb;
    ffifo_din(0) <= font_px;
    prefetch_proc : process (pxclk)
    begin
        if rising_edge(pxclk) then
            if (rst_n = '0') then
                prefetch_state  <= PREFETCH_IDLE;
                game_en         <= '0';
                color_en        <= '0';
                font_en         <= '0';
                bfifo_wreq      <= '0';
                ffifo_wreq      <= '0';
            else
                case prefetch_state is

                    when PREFETCH_IDLE =>
                        if (vga_valid = '1') and (vga_x = 0) and (is_blk_y = '1') then
                            prefetch_state   <= FETCH_BLOCKS;
                            game_en          <= '1';
                            game_blk_score_n <= '1';
                            prefetch_hpos    <= 0;
                            color_en         <= '1';
                            bfifo_wreq       <= '1';
                            if (vga_y = GRID_Y) then
                                prefetch_vpos   <= 0;
                                prefetch_blk_y  <= 0;
                            else
                                if (prefetch_blk_y < BLOCK_H-1) then
                                    prefetch_blk_y <= prefetch_blk_y + 1;
                                else
                                    prefetch_vpos   <= prefetch_vpos + 1;
                                    prefetch_blk_y  <= 0;
                                end if;
                            end if;
                        end if;

                    when FETCH_BLOCKS =>
                        if (prefetch_hpos < GRID_W-1) then
                            prefetch_hpos <= prefetch_hpos + 1;
                        else
                            color_en   <= '0';
                            bfifo_wreq <= '0';
                            if (is_score_y = '1') then
                                prefetch_state   <= FETCH_SCORE;
                                game_blk_score_n <= '0';
                                prefetch_hpos    <= 0;
                                font_en          <= '1';
                                font_x           <= (others => '0');
                                ffifo_wreq       <= '1';
                                if (vga_y = SCORE_X) then
                                    font_y               <= (others => '0');
                                    prefetch_font_vscale <= 0;
                                else
                                    if (prefetch_font_vscale < FONT_SCALE-1) then
                                        prefetch_font_vscale <= prefetch_font_vscale + 1;
                                    else
                                        font_y               <= font_y + 1;
                                        prefetch_font_vscale <= 0;
                                    end if;
                                end if;
                            else
                                prefetch_state <= PREFETCH_IDLE;
                                game_en        <= '0';
                            end if;
                        end if;

                    when FETCH_SCORE =>
                        if (font_x < FONT_W-1) then
                            font_x    <= font_x + 1;
                        else
                            if (prefetch_hpos < SCORE_W-1) then
                                prefetch_hpos <= prefetch_hpos + 1;
                                font_x        <= (others => '0');
                            else
                                prefetch_state  <= PREFETCH_IDLE;
                                game_en         <= '0';
                                font_en         <= '0';
                                ffifo_wreq      <= '0';
                            end if;
                        end if;

                    when others =>
                        prefetch_state  <= PREFETCH_IDLE;
                        game_en         <= '0';
                        color_en        <= '0';
                        font_en         <= '0';
                        bfifo_wreq      <= '0';
                        ffifo_wreq      <= '0';

                end case; -- prefetch_state
            end if; -- (rst_n = '0')
        end if; -- rising_edge(pxclk)
    end process; -- prefetch_proc
    --------------------------------------------------
    -- END: PREFETCH FSM
    --------------------------------------------------


    --------------------------------------------------
    -- BEGIN: DRAW FSM
    --------------------------------------------------
    draw_proc : process (pxclk)
    begin
        if rising_edge(pxclk) then
            if (rst_n = '0') then
                draw_state  <= DRAW_IDLE;
                vga_rgb     <= x"000000";
                bfifo_rack  <= '0';
                ffifo_rack  <= '0';
            else
                case draw_state is

                    when DRAW_IDLE =>
                        if (is_blk_y = '1') then
                            -- block row
                            if (is_pre_grid_x = '1') then
                                -- draw left border and get first block color
                                draw_state  <= DRAW_BORDER_L;
                                vga_rgb     <= x"FFFFFF";
                                bfifo_rack  <= '1';
                                draw_hscale <= 0;
                            end if;
                        end if;
                        if (is_score_y = '1') then
                            -- score row
                            if (is_pre_score_x = '1') then
                                -- get first score pixel
                                ffifo_rack  <= '1';
                            end if;
                            if (is_pre_score_x2 = '1') then
                                -- start drawing score
                                draw_state  <= DRAW_SCORE;
                                ffifo_rack  <= '0';
                                if (ffifo_dout = "1") then
                                    vga_rgb <= x"FFFFFF";
                                else
                                    vga_rgb <= x"000000";
                                end if;
                            end if;
                        end if;
                        if (is_border_b_y = '1') then
                            -- bottom border row
                            if (is_pre_grid_x = '1') then
                                -- start botton border
                                draw_state    <= DRAW_BORDER_B;
                                vga_rgb       <= x"FFFFFF";
                            end if;
                        end if;

                    when DRAW_BORDER_L =>
                        draw_state  <= DRAW_BLOCKS;
                        vga_rgb     <= bfifo_dout;
                        bfifo_rack  <= '0';
                        draw_blk_x  <= 0;

                    when DRAW_BLOCKS =>
                        if (draw_blk_x < BLOCK_W-1) then
                            draw_blk_x <= draw_blk_x + 1;
                        else
                            -- end of block
                            if (is_post_grid_x2 = '1') then
                                -- end of grid
                                draw_state  <= DRAW_BORDER_R;
                                vga_rgb     <= x"FFFFFF";
                            else
                                -- start next block
                                vga_rgb     <= bfifo_dout;
                                bfifo_rack  <= '0';
                                draw_blk_x  <= 0;
                            end if;
                        end if;
                        if (draw_blk_x = BLOCK_W-2) and (is_post_grid_x = '0') then
                            -- get next block color if not end of grid
                            bfifo_rack  <= '1';
                        end if;

                    when DRAW_BORDER_R =>
                        draw_state  <= DRAW_IDLE;
                        vga_rgb     <= x"000000";

                    when DRAW_SCORE =>
                        if (is_post_score_x2 = '1') then
                            draw_state  <= DRAW_IDLE;
                            vga_rgb     <= x"000000";
                        else
                            if (draw_hscale < FONT_SCALE-1) then
                                draw_hscale <= draw_hscale + 1;
                            else
                                if (ffifo_dout = "1") then
                                    vga_rgb <= x"FFFFFF";
                                else
                                    vga_rgb <= x"000000";
                                end if;
                                ffifo_rack  <= '0';
                                draw_hscale <= 0;
                            end if;
                        end if;
                        if (draw_hscale = FONT_SCALE-2) and (is_post_score_x = '0') then
                            ffifo_rack  <= '1';
                        end if;

                    when DRAW_BORDER_B =>
                        if (is_post_grid_x = '1') then
                            draw_state <= DRAW_BORDER_R;
                        end if;

                    WHEN others =>
                        draw_state  <= DRAW_IDLE;
                        vga_rgb     <= x"000000";
                        bfifo_rack  <= '0';
                        ffifo_rack  <= '0';

                end case; -- draw_state
            end if; -- (rst_n = '0')
        end if; -- rising_edge(pxclk)
    end process; -- draw_proc
    --------------------------------------------------
    -- END: DRAW FSM
    --------------------------------------------------

end architecture behavioral;
