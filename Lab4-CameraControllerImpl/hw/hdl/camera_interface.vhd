library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity camera_interface is
Port(
    Clk             : IN std_logic; -- Clk will be PIXCLK from Camera
    nReset          : IN std_logic;

    -- Camera input signals
    CamData         : IN std_logic_vector (4 DOWNTO 0);
    LValid          : IN std_logic;
    FValid          : IN std_logic;

    -- Sensor LineFIFO signals
    LineFIFOrreq    : OUT std_logic;
    LineFIFOwreq    : OUT std_logic;
    LineFIFOData    : IN std_logic_vector (4 DOWNTO 0);
    LineFIFOempty   : IN std_logic;

    -- output signals
    PixelDatawreq   : OUT std_logic;
    PixelData       : OUT std_logic_vector (15 DOWNTO 0);
    AddressUpdate   : OUT std_logic
);
End camera_interface;

Architecture comp of camera_interface is
    type BayerStateType is (
        IDLE,
        BLUE, -- receive BLUE and GREEN1 sensor values
        RED   -- receive RED and GREEN2 sensor values
    );
    signal BayerState   : BayerStateType;

    type LineStateType is (
        LBUFFER,
        LPROCESS,
        LSKIP1,
        LSKIP2
    );
    signal LineState    : LineStateType;

    signal BayerActive  : std_logic;

    signal BlueCache : std_logic_vector(4 DOWNTO 0);
    signal GreenCache : std_logic_vector(4 DOWNTO 0);
begin
    pBayerFSM: process(Clk, nReset)
    begin
        if nReset = '0' then
            BayerState <= IDLE;
            PixelData(1 DOWNTO 0) <= (others => '0');
        elsif rising_edge(Clk) then
            if BayerActive = '0' then
                BayerState <= IDLE;
            else
                case BayerState is
                    when IDLE =>
                        BayerState <= BLUE;
                    when BLUE =>
                        BlueCache <= CamData;
                        GreenCache <= LineFIFOData;
                        BayerState <= RED;
                    when RED =>
                        PixelData(15 DOWNTO 11) <= LineFIFOData;
                        PixelData(4 DOWNTO 0) <= BlueCache;
                        PixelData(10 DOWNTO 5) <= std_logic_vector(
                                                    unsigned('0' & GreenCache)
                                                  + unsigned(CamData)
                                                );
                        BayerState <= BLUE;
                end case;
            end if;
        end if;
    end process;

    BayerActive <= '1' when LValid = '1' and
                            FValid = '1' and
                            LineState = LPROCESS
                            else '0';

    pLineFSM: process(Clk, nReset)
    variable last_lvalid: std_logic;
    begin
        if nReset = '0' or FValid = '0' then
            last_lvalid := '0';
            LineState <= LBUFFER;
        elsif rising_edge(Clk) then
            -- falling edge of LValid
            if (not LValid and last_lvalid) = '1' then
                case LineState is
                    when LBUFFER    => LineState <= LPROCESS;
                    when LPROCESS   => LineState <= LSKIP1;
                    when LSKIP1     => LineState <= LSKIP2;
                    when LSKIP2     => LineState <= LBUFFER;
                end case;
            end if;
            last_lvalid := LValid;
        end if;
    end process;


    pFrameStart: process(Clk, nReset)
    variable last_fvalid: std_logic;
    begin
        if nReset = '0' or FValid = '0' then
            last_fvalid := '0';
            AddressUpdate <= '0';
        elsif rising_edge(Clk) then
            -- rising edge of FValid
            if (FValid and not last_fvalid) = '1' then
                AddressUpdate <= '1';
            else
                AddressUpdate <= '0';
            end if;
            last_fvalid := FValid;
        end if;
    end process;

end comp;
