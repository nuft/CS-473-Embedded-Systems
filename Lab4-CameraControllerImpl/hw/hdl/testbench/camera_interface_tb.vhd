library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

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
              PixelData     : out std_logic_vector (15 downto 0);
              AddressUpdate : out std_logic);
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
    signal AddressUpdate : std_logic;

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
              PixelData     => PixelData,
              AddressUpdate => AddressUpdate);

    -- Clock generation
    tb_clk <= not tb_clk after clk_period/2 when sim_ended /= '1' else '0';
    Clk <= tb_clk;

    stimulus : process

    -- to string functions
    function to_bstring(sl : std_logic) return string is
        variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
    begin
        sl_str_v := std_logic'image(sl);
        return "" & sl_str_v(2);  -- "" & character to get string
    end function;

    function to_bstring(slv : std_logic_vector) return string is
        alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
        variable sl_str_v : string(1 to 1);  -- String of std_logic
        variable res_v    : string(1 to slv'length);
    begin
        for idx in slv_norm'range loop
            sl_str_v := to_bstring(slv_norm(idx));
            res_v(idx) := sl_str_v(1);
        end loop;
        return res_v;
    end function;

    procedure TEST_BayerToRGB is
    begin
        LValid <= '1';
        FValid <= '1';

        CamData <= "10101"; -- blue
        LineFIFOData <= "11111"; -- green1
        wait for clk_period;
        CamData <= "00001"; -- green2
        LineFIFOData <= "11100"; -- red
        wait for clk_period;

        assert unsigned(PixelData) = B"11100_100000_10101"
        report "ASSERT FAILED"  & LF &
               "PixelData = " & to_bstring(PixelData) & LF &
               "Expected:   " & B"11100_100000_10101"
               severity failure;

    end procedure TEST_BayerToRGB;

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
        -- TEST_BayerToRGB;

        FValid <= '1';
        wait until falling_edge(clk);
        LValid <= '1';
        wait until rising_edge(clk);
        wait for 4 * clk_period;
        LValid <= '0';
        wait for 2 * clk_period;
        wait until falling_edge(clk);
        LValid <= '1';
        wait until rising_edge(clk);
        wait for 4 * clk_period;
        LValid <= '0';
        FValid <= '0';

        wait for 10 * clk_period;

        report "DONE" & LF & ">> OK" & LF;
        -- Stop the clock and hence terminate the simulation
        sim_ended <= '1';
        wait;
    end process;

end tb;
