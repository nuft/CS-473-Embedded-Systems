library ieee;
use ieee.std_logic_1164.all;

Entity CameraAvalonSlave is
Port(
    Clk             : IN std_logic;
    Reset_n         : IN std_logic;

    -- Avalon Slave
    Address         : IN std_logic_vector (2 DOWNTO 0);
    ChipSelect      : IN std_logic;
    Read            : IN std_logic;
    Write           : IN std_logic;
    ReadData        : OUT std_logic_vector (31 DOWNTO 0);
    WriteData       : IN std_logic_vector (31 DOWNTO 0);

    -- output signals
    Irq             : OUT std_logic;
    ImageAddress    : OUT std_logic_vector (31 DOWNTO 0);
    AddressUpdate   : OUT std_logic;

    -- Input signals
    ImageStartIrq   : IN std_logic;
    ImageEndIrq     : IN std_logic
);
End CameraAvalonSlave;

Architecture comp of CameraAvalonSlave is
-- signals for register access
   signal   iControlRegister        :  std_logic_vector (1 DOWNTO 0);
   signal   iInterruptMaskRegister  :  std_logic_vector (1 DOWNTO 0);
   signal   iInterruptStatusRegister:  std_logic_vector (1 DOWNTO 0);
   signal   iImageAddressRegister   :  std_logic_vector (31 DOWNTO 0);
begin
    -- Register access
    pRegWr: process(Clk, nReset)
        begin
            if nReset = '0' then
                -- Register reset values
                iControlRegister <= (others => '0');
                iInterruptMaskRegister <= (others => '0');
                iInterruptStatusRegister <= (others => '0');
                iImageAddressRegister <= (others => '0');

                -- output signals
                ImageAddress <= (others => '0');
                AddressUpdate <= '0';

            elsif rising_edge(Clk) then
                ReadData <= (others => '0'); -- default value
                -- Read registers
                if ChipSelect = '1' and Read = '1' then
                    case Address(1 downto 0) is
                        when '00' => ReadData(1 downto 0) <= iControlRegister;
                        when '01' => ReadData(1 downto 0) <= iInterruptMaskRegister;
                        when '10' => ReadData(1 downto 0) <= iInterruptStatusRegister;
                        when '11' => ReadData <= iImageAddressRegister;
                        when others => null;
                    end case;

                -- Write registers
                elsif ChipSelect = '1' and Write = '1' then -- Write cycle
                    case Address(1 downto 0) is
                        when '00' => iControlRegister <= WriteData(1 DOWNTO 0);
                        when '01' => iInterruptMaskRegister <= WriteData(1 DOWNTO 0);
                        when '10' => iInterruptStatusRegister <= WriteData(1 DOWNTO 0);
                        when '11' => iImageAddressRegister <= WriteData;
                        when others => null;
                    end case;
                end if;
            end if;
        end process;

    -- Interrupt logic
    pRegRd: process(Clk, nReset)
        begin
            if nReset = '0' then
                Irq <= '0';
            elsif rising_edge(Clk) then
                Irq <= '1' when (ImageEndIrq and iInterruptMaskRegister(0)) = '1' else
                       '1' when (ImageStartIrq and iInterruptMaskRegister(1)) = '1' else
                       '0';
            end if;
    end process;

end comp;
