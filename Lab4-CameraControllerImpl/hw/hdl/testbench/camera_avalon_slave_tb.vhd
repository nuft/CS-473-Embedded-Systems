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
              ImageStartIrq => ImageStartIrq,
              ImageEndIrq   => ImageEndIrq);

    -- Clock generation
    tb_clk <= not tb_clk after clk_period/2 when sim_ended /= '1' else '0';
    Clk <= tb_clk;

    stimulus: process
        -- Simulate Avalon write
        procedure AvalonWrite(
            constant addr    : std_logic_vector(1 DOWNTO 0);
            constant data    : unsigned(31 DOWNTO 0)) is
        begin
            Address <= addr;
            ChipSelect <= '1';
            Read <= '0';
            Write <= '1';
            WriteData <= std_logic_vector(data);
            wait until rising_edge(tb_clk);
            wait for clk_period;
            WriteData <= (others => '0');
            Address <= (others => '0');
            ChipSelect <= '0';
            Write <= '0';
        end procedure AvalonWrite;
    begin


        Address <= (others => '0');
        ChipSelect <= '0';
        Read <= '0';
        Write <= '0';
        WriteData <= (others => '0');
        ImageStartIrq <= '0';
        ImageEndIrq <= '0';

        -- Reset generation
        wait for clk_period/4;
        nReset <= '0';
        wait for clk_period/4;
        nReset <= '1';
        wait for clk_period;

        -- Write ControlRegister
        AvalonWrite("00", to_unsigned(1, 32));

        -- Write InterruptMaskRegister
        Address <= "01";
        ChipSelect <= '1';
        WriteData <= std_logic_vector(to_unsigned(16#3#, WriteData'length));
        Write <= '1';
        wait for clk_period;
        Write <= '0';
        ChipSelect <= '0';
        WriteData <= std_logic_vector(to_unsigned(0, WriteData'length));
        wait for clk_period;

        -- Write ImageAddressRegister
        Address <= "11";
        ChipSelect <= '1';
        WriteData <= std_logic_vector(to_unsigned(16#2ac0ffee#, WriteData'length));
        Write <= '1';
        wait for clk_period;
        Write <= '0';
        ChipSelect <= '0';
        WriteData <= std_logic_vector(to_unsigned(0, WriteData'length));
        wait for clk_period;

        assert unsigned(ImageAddress) = 16#2ac0ffee#
        report "Does not keep ImageAddress" severity failure;
        assert AddressUpdate = '1'
        report "Does not signal AddressUpdate" severity failure;

        wait for 3*clk_period;

        -- Stop the clock and hence terminate the simulation
        sim_ended <= '1';
        wait;
    end process;

end tb;
