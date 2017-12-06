library ieee;
use ieee.std_logic_1164.all;

Entity camera_avalon_slave is
Port(
    Clk             : IN std_logic;
    nReset          : IN std_logic;

    -- Avalon Slave
    Address         : IN std_logic_vector (1 DOWNTO 0);
    ChipSelect      : IN std_logic;
    Read            : IN std_logic;
    Write           : IN std_logic;
    ReadData        : OUT std_logic_vector (31 DOWNTO 0);
    WriteData       : IN std_logic_vector (31 DOWNTO 0);

    -- output signals
    Irq             : OUT std_logic;
    ImageAddress    : OUT std_logic_vector (31 DOWNTO 0);
    AddressUpdate   : OUT std_logic;
    CameraIfEnable: OUT std_logic;
    MasterEnable    : OUT std_logic;
    Camera_nReset   : OUT std_logic;

    -- Input signals
    ImageStartIrq   : IN std_logic;
    ImageEndIrq     : IN std_logic
);
End camera_avalon_slave;

Architecture comp of camera_avalon_slave is
-- signals for register access
   signal   iRegControl        :  std_logic_vector (1 DOWNTO 0);
   signal   iRegInterruptMask  :  std_logic_vector (1 DOWNTO 0);
   signal   iRegInterruptStatus:  std_logic_vector (1 DOWNTO 0);
   signal   iRegImageAddress   :  std_logic_vector (31 DOWNTO 0);
begin
    -- Register write
    pRegWr: process(Clk, nReset)
    begin
        if nReset = '0' then
            -- Register reset values
            iRegControl <= (others => '0');
            iRegInterruptMask <= (others => '0');
            iRegInterruptStatus <= (others => '0');
            iRegImageAddress <= (others => '0');

            -- output signals
            ImageAddress <= (others => '0');
            AddressUpdate <= '0';

        elsif rising_edge(Clk) then
            -- default values
            AddressUpdate <= '0';

            -- set Interrupt Status Register on interrupt signals
            iRegInterruptStatus <= iRegInterruptStatus or (ImageStartIrq & ImageEndIrq);

            -- Write registers
            if ChipSelect = '1' and Write = '1' then -- Write cycle
                case Address(1 downto 0) is
                    when "00" => iRegControl <= WriteData(1 DOWNTO 0);
                    when "01" => iRegInterruptMask <= WriteData(1 DOWNTO 0);
                    when "10" => iRegInterruptStatus <= iRegInterruptStatus and not WriteData(1 DOWNTO 0);
                    when "11" =>
                        iRegImageAddress <= WriteData;
                        ImageAddress <= WriteData;
                        AddressUpdate <= '1';
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Register read
    pRegRd: process(Clk)
    begin
        if rising_edge(Clk) then
            -- default values
            ReadData <= (others => '0');

            -- Read registers
            if ChipSelect = '1' and Read = '1' then
                case Address(1 downto 0) is
                    when "00" => ReadData(1 downto 0) <= iRegControl;
                    when "01" => ReadData(1 downto 0) <= iRegInterruptMask;
                    when "10" => ReadData(1 downto 0) <= iRegInterruptStatus;
                    when "11" => ReadData <= iRegImageAddress;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Enable Out
    pEnOut: process(Clk, nReset)
    begin
        if nReset = '0' then
            CameraIfEnable <= '0';
            MasterEnable <= '0';
        elsif rising_edge(Clk) then
            CameraIfEnable <= iRegControl(0);
            MasterEnable <= iRegControl(0);
            Camera_nReset <= iRegControl(1);
        end if;
    end process;

    -- Interrupt logic
    pInt: process(Clk, nReset)
    begin
        if nReset = '0' then
            Irq <= '0';
        elsif rising_edge(Clk) then
            Irq <= '0';
            if (iRegInterruptStatus and iRegInterruptMask) /= "00" then
                Irq <= '1';
            end if;
        end if;
    end process;

end comp;
