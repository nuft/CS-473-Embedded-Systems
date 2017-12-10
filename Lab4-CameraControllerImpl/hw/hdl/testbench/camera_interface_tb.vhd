library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera_interface_tb is
end camera_interface_tb;

architecture tb of camera_interface_tb is

    component camera_interface
        port (Clk           : in std_logic;
              nReset        : in std_logic;
              CamData       : in std_logic_vector (4 downto 0);
              LValid        : in std_logic;
              FValid        : in std_logic;
              LineFIFOrreq  : out std_logic;
              LineFIFOwreq  : out std_logic;
              LineFIFOData  : in std_logic_vector (4 DOWNTO 0);
              LineFIFOempty : in std_logic;
              PixelDatawreq : out std_logic;
              PixelData     : out std_logic_vector (15 downto 0));
    end component;

    signal Clk           : std_logic;
    signal nReset        : std_logic;
    signal CamData       : std_logic_vector (4 downto 0);
    signal LValid        : std_logic;
    signal FValid        : std_logic;
    signal LineFIFOrreq  : std_logic;
    signal LineFIFOwreq  : std_logic;
    signal LineFIFOData  : std_logic_vector (4 DOWNTO 0);
    signal LineFIFOempty : std_logic;
    signal PixelDatawreq : std_logic;
    signal PixelData     : std_logic_vector (15 downto 0);

    constant clk_period : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal sim_ended : std_logic := '0';

begin

    dut : camera_interface
    port map (Clk           => Clk,
              nReset        => nReset,
              CamData       => CamData,
              LValid        => LValid,
              FValid        => FValid,
              LineFIFOrreq  => LineFIFOrreq,
              LineFIFOwreq  => LineFIFOwreq,
              LineFIFOData  => LineFIFOData,
              LineFIFOempty => LineFIFOempty,
              PixelDatawreq => PixelDatawreq,
              PixelData     => PixelData);

    -- Clock generation
    tb_clk <= not tb_clk after clk_period/2 when sim_ended /= '1' else '0';
    Clk <= tb_clk;

    stimulus : process

    -- Reset UUT
    procedure TEST_RESET is
    begin
        -- init values
        CamData <= (others => '0');
        LValid <= '0';
        FValid <= '0';
        LineFIFOData <= (others => '0');
        LineFIFOempty <= '0';

        -- RESET generation
        wait for clk_period/4;
        nReset <= '0';
        wait for clk_period/4;
        nReset <= '1';
        wait until rising_edge(tb_clk);
    end procedure TEST_RESET;

    begin
        report "START TESTBENCH" & LF;

        TEST_RESET;

        wait for 10 * clk_period;

        report "DONE" & LF & ">> OK" & LF;

        -- Stop the clock and hence terminate the simulation
        sim_ended <= '1';
        wait;
    end process;

end tb;
