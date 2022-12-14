library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ADC_Controller is
    generic (
        CLK_FREQ : integer;     -- Clock frequency in Hz of clk
        SAMPLE_FREQ : integer   -- Rate of ADC sample update
    );
    port (
        clk             : in std_logic;
        rst_n           : in std_logic;
        adc_pll_clk     : in std_logic;
        adc_pll_locked  : in std_logic;
        dout            : out std_logic_vector(11 downto 0)
    );
end entity ADC_Controller;


architecture behavioral of ADC_Controller is

    component ADC is
        port (
            clock_clk              : in  std_logic                     := 'X';             -- clk
            reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
            adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
            adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
            command_valid          : in  std_logic                     := 'X';             -- valid
            command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
            command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
            command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
            command_ready          : out std_logic;                                        -- ready
            response_valid         : out std_logic;                                        -- valid
            response_channel       : out std_logic_vector(4 downto 0);                     -- channel
            response_data          : out std_logic_vector(11 downto 0);                    -- data
            response_startofpacket : out std_logic;                                        -- startofpacket
            response_endofpacket   : out std_logic                                         -- endofpacket
        );
    end component ADC;


    constant DELAY_CLOCKS : natural := CLK_FREQ / SAMPLE_FREQ;
    signal count : unsigned(31 downto 0);

    -- Registers
    signal read  : std_logic;

    -- Wires
    signal ready : std_logic;
    signal valid : std_logic;
    signal din   : std_logic_vector(11 downto 0);

begin

    ADC0 : component ADC
        port map (
            clock_clk               => clk,
            reset_sink_reset_n      => rst_n,
            adc_pll_clock_clk       => adc_pll_clk,
            adc_pll_locked_export   => adc_pll_locked,
            command_valid           => read,
            command_channel         => "00001",
            command_startofpacket   => '1',
            command_endofpacket     => '0',
            command_ready           => ready,
            response_valid          => valid,
            response_data           => din
        );

    main_proc : process (clk)
    begin
        if rising_edge(clk) then
            if (rst_n = '0') then
                read  <= '0';
                count <= (others => '0');
                dout  <= (others => '0');
            else
                if (count >= DELAY_CLOCKS) then
                    read <= '1';
                    if (valid = '1') then
                        dout  <= din;
                        count <= (others => '0');
                    end if; -- valid
                else
                    read <= '0';
                    count <= count + 1;
                end if;
            end if; -- rst_n = '0'
        end if; -- rising_edge(clk)
    end process;

end behavioral ; -- ADC_Controller