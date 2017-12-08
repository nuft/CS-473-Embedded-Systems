library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera_avalon_slave_tb is
end camera_avalon_slave_tb;

architecture tb of camera_avalon_slave_tb is

    component camera_avalon_slave
        port (Clk           : in std_logic;
              nReset        : in std_logic;
              Address       : in std_logic_vector (1 downto 0);
              ChipSelect    : in std_logic;
              Read          : in std_logic;
              Write         : in std_logic;
              ReadData      : out std_logic_vector (31 downto 0);
              WriteData     : in std_logic_vector (31 downto 0);
              Irq           : out std_logic;
              ImageAddress  : out std_logic_vector (31 downto 0);
              AddressUpdate : out std_logic;
              CameraIfEnable: out std_logic;
              MasterEnable  : out std_logic;
              Camera_nReset : out std_logic;
              ImageStartIrq : in std_logic;
              ImageEndIrq   : in std_logic);
    end component;

    signal Clk           : std_logic;
    signal nReset        : std_logic;
    signal Address       : std_logic_vector (1 downto 0);
    signal ChipSelect    : std_logic;
    signal Read          : std_logic;
    signal Write         : std_logic;
    signal ReadData      : std_logic_vector (31 downto 0);
    signal WriteData     : std_logic_vector (31 downto 0);
    signal Irq           : std_logic;
    signal ImageAddress  : std_logic_vector (31 downto 0);
    signal AddressUpdate : std_logic;
    signal CameraIfEnable: std_logic;
    signal MasterEnable  : std_logic;
    signal Camera_nReset : std_logic;
    signal ImageStartIrq : std_logic;
    signal ImageEndIrq   : std_logic;

    constant clk_period : time := 20 ns; -- EDIT Put right period here
    signal tb_clk : std_logic := '0';
    signal sim_ended : std_logic := '0';

begin

    dut : camera_avalon_slave
    port map (Clk           => Clk,
              nReset        => nReset,
              Address       => Address,
              ChipSelect    => ChipSelect,
              Read          => Read,
              Write         => Write,
              ReadData      => ReadData,
              WriteData     => WriteData,
              Irq           => Irq,
              ImageAddress  => ImageAddress,
              AddressUpdate => AddressUpdate,
              CameraIfEnable=> CameraIfEnable,
              MasterEnable  => MasterEnable,
              Camera_nReset => Camera_nReset,
              ImageStartIrq => ImageStartIrq,
              ImageEndIrq   => ImageEndIrq);

    -- Clock generation
    tb_clk <= not tb_clk after clk_period/2 when sim_ended /= '1' else '0';
    Clk <= tb_clk;

stimulus: process
    constant REG_CR: std_logic_vector(1 DOWNTO 0) := "00";
    constant REG_IMR: std_logic_vector(1 DOWNTO 0) := "01";
    constant REG_ISR: std_logic_vector(1 DOWNTO 0) := "10";
    constant REG_IAR: std_logic_vector(1 DOWNTO 0) := "11";

    -- ISR bit mask
    constant END_IRQ: natural := 1;
    constant START_IRQ: natural := 2;
    -- CR bit mask
    constant PERIPH_EN: natural := 1;
    constant CAM_EN: natural := 2;

    -- Simulate Avalon write
    procedure AvalonWrite(
        constant addr: std_logic_vector(1 DOWNTO 0);
        constant data: unsigned(31 DOWNTO 0)) is
    begin
        wait until rising_edge(tb_clk);
        Address <= addr;
        ChipSelect <= '1';
        Read <= '0';
        Write <= '1';
        WriteData <= std_logic_vector(data);
        wait for clk_period;
        WriteData <= (others => '0');
        Address <= (others => '0');
        ChipSelect <= '0';
        Write <= '0';
    end procedure AvalonWrite;

    -- Simulate Avalon read
    procedure AvalonRead(
        constant addr: std_logic_vector(1 DOWNTO 0)) is
    begin
        wait until rising_edge(tb_clk);
        Address <= addr;
        ChipSelect <= '1';
        Read <= '1';
        Write <= '0';
        wait for clk_period;
        Address <= (others => '0');
        ChipSelect <= '0';
        Read <= '0';
    end procedure AvalonRead;

    procedure TEST_ImageAddress is
    begin
        -- Write Image Address Register
        AvalonWrite(REG_IAR, to_unsigned(16#c0ffee#, 32));
        assert unsigned(ImageAddress) = 16#c0ffee#
        report "Does not keep ImageAddress" severity failure;

        -- check Address update
        wait for clk_period;
        Address <= REG_IAR;
        ChipSelect <= '1';
        WriteData <= std_logic_vector(to_unsigned(42, WriteData'length));
        Write <= '1';
        wait for clk_period / 2;
        assert AddressUpdate = '1'
        report "AddressUpdate not signaled" severity failure;
        wait for clk_period / 2;
        Write <= '0';
        ChipSelect <= '0';
        WriteData <= std_logic_vector(to_unsigned(0, WriteData'length));
        wait for clk_period / 2;
        assert AddressUpdate = '0'
        report "AddressUpdate not cleared" severity failure;
        wait until rising_edge(tb_clk);
    end procedure TEST_ImageAddress;

    procedure TEST_Avalon is
    begin
        AvalonWrite(REG_CR, to_unsigned(3, 32));
        AvalonRead(REG_CR);
        assert unsigned(ReadData) = to_unsigned(3, 32)
        report "AvalonRead /= AvalonWrite" severity failure;
        AvalonWrite(REG_IMR, to_unsigned(3, 32));
        AvalonRead(REG_IMR);
        assert unsigned(ReadData) = to_unsigned(3, 32)
        report "AvalonRead /= AvalonWrite" severity failure;
        AvalonWrite(REG_IAR, to_unsigned(123456, 32));
        AvalonRead(REG_IAR);
        assert unsigned(ReadData) = to_unsigned(123456, 32)
        report "AvalonRead /= AvalonWrite" severity failure;
    end procedure TEST_Avalon;

    procedure TEST_InterruptSetClear is
    begin
        ImageEndIrq <= '0';
        ImageStartIrq <= '1';
        wait for clk_period;
        ImageStartIrq <= '0';
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(START_IRQ, 32)
        report "START_IRQ not set" severity failure;
        AvalonWrite(REG_ISR, to_unsigned(START_IRQ, 32));
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(0, 32)
        report "START_IRQ not cleared" severity failure;

        ImageEndIrq <= '1';
        ImageStartIrq <= '0';
        wait for clk_period;
        ImageEndIrq <= '0';
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(END_IRQ, 32)
        report "END_IRQ not set" severity failure;
        AvalonWrite(REG_ISR, to_unsigned(END_IRQ, 32));
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(0, 32)
        report "END_IRQ not cleared" severity failure;

        ImageEndIrq <= '1';
        ImageStartIrq <= '1';
        wait for clk_period;
        ImageEndIrq <= '0';
        ImageStartIrq <= '0';
        AvalonWrite(REG_ISR, to_unsigned(END_IRQ, 32));
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(START_IRQ, 32)
        report "END_IRQ not cleared" severity failure;

        -- check if writing 0 keeps intrrupt flags
        ImageEndIrq <= '1';
        ImageStartIrq <= '1';
        wait for clk_period;
        ImageEndIrq <= '0';
        ImageStartIrq <= '0';
        AvalonWrite(REG_ISR, to_unsigned(0, 32));
        AvalonRead(REG_ISR);
        assert unsigned(ReadData) = to_unsigned(START_IRQ + END_IRQ, 32)
        report "IRQ flags not set" severity failure;

    end procedure TEST_InterruptSetClear;

    -- Interrupt Mask test
    procedure TEST_InterruptMask is
    begin
        -- Test Interrupt mask
        ImageStartIrq <= '0';
        ImageEndIrq <= '1';
        AvalonWrite(REG_IMR, to_unsigned(0, 32));
        wait for clk_period;
        assert Irq = '0'
        report "IRQ ImageEndIrq not masked" severity failure;

        ImageStartIrq <= '0';
        ImageEndIrq <= '1';
        AvalonWrite(REG_ISR, to_unsigned(END_IRQ + START_IRQ, 32)); -- clear ISR
        AvalonWrite(REG_IMR, to_unsigned(END_IRQ, 32));
        wait for clk_period;
        assert Irq = '1'
        report "IRQ ImageEndIrq not activated" severity failure;

        ImageStartIrq <= '1';
        ImageEndIrq <= '0';
        AvalonWrite(REG_ISR, to_unsigned(END_IRQ + START_IRQ, 32)); -- clear ISR
        AvalonWrite(REG_IMR, to_unsigned(START_IRQ, 32));
        wait for clk_period;
        assert Irq = '1'
        report "IRQ ImageStart not activated" severity failure;

        ImageStartIrq <= '1';
        ImageEndIrq <= '0';
        AvalonWrite(REG_ISR, to_unsigned(END_IRQ + START_IRQ, 32)); -- clear ISR
        AvalonWrite(REG_IMR, to_unsigned(0, 32));
        wait for clk_period;
        assert Irq = '0'
        report "IRQ ImageStart not masked" severity failure;
    end procedure TEST_InterruptMask;

    -- Enable output signals test case
    procedure TEST_EnableOut is
    begin
        AvalonWrite(REG_CR, to_unsigned(PERIPH_EN, 32));
        wait for clk_period;
        assert CameraIfEnable = '1' and MasterEnable = '1'
        report "Peripheral not enabled" severity failure;
        assert Camera_nReset = '0'
        report "Camera not disabled" severity failure;

        AvalonWrite(REG_CR, to_unsigned(CAM_EN, 32));
        wait for clk_period;
        assert CameraIfEnable = '0' and MasterEnable = '0'
        report "Peripheral not disabled" severity failure;
        assert Camera_nReset = '1'
        report "Camera not enabled" severity failure;
    end procedure TEST_EnableOut;

    -- Reset UUT
    procedure TEST_RESET is
    begin
        -- init values
        Address <= (others => '0');
        ChipSelect <= '0';
        Read <= '0';
        Write <= '0';
        WriteData <= (others => '0');
        ImageStartIrq <= '0';
        ImageEndIrq <= '0';

        -- RESET generation
        wait for clk_period/4;
        nReset <= '0';
        wait for clk_period/4;
        nReset <= '1';
        wait until rising_edge(tb_clk);
    end procedure TEST_RESET;

begin -- TEST PROCESS
    report "START TESTBENCH" & LF;

    TEST_RESET;
    TEST_ImageAddress;

    TEST_RESET;
    TEST_Avalon;

    TEST_RESET;
    TEST_InterruptSetClear;

    TEST_RESET;
    TEST_InterruptMask;

    TEST_RESET;
    TEST_EnableOut;

    report "DONE" & LF & ">> OK" & LF;
    -- Stop the clock and hence terminate the simulation
    sim_ended <= '1';
    wait;
end process;

end tb;
