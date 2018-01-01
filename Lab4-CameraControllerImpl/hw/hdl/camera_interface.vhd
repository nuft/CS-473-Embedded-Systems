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
    LineFIFOclear   : OUT std_logic;

    -- output signals
    PixFIFOwreq     : OUT std_logic;
    PixFIFOData     : OUT std_logic_vector (15 DOWNTO 0);
    PixFIFOaclr     : OUT std_logic;
    AddressUpdate   : OUT std_logic;

    -- debug signals
    DEBUG_BayerState      : OUT std_logic_vector (1 DOWNTO 0);
    DEBUG_PixelState      : OUT std_logic_vector (1 DOWNTO 0);
    DEBUG_LineState       : OUT std_logic_vector (1 DOWNTO 0)
);
End camera_interface;

Architecture comp of camera_interface is
    type BayerStateType is (
        IDLE,
        BLUE, -- receive BLUE and GREEN1 sensor values
        RED   -- receive RED and GREEN2 sensor values
    );
    signal BayerState   : BayerStateType;

    type PixelStateType is (
        IDLE,
        PPROCESS,
        POUTPUT,
        PSKIP
    );
    signal PixelState   : PixelStateType;

    type LineStateType is (
        LBUFFER,
        LPROCESS,
        LSKIP1,
        LSKIP2
    );
    signal LineState    : LineStateType;

    signal BayerActive  : std_logic;

    signal CamDataBuf : std_logic_vector(4 DOWNTO 0);
    signal BlueCache : std_logic_vector(4 DOWNTO 0);
    signal GreenCache : std_logic_vector(4 DOWNTO 0);

begin
    pDebug: process(BayerState, PixelState, LineState)
    begin
        case BayerState is
            when IDLE => DEBUG_BayerState <= "00";
            when BLUE => DEBUG_BayerState <= "01";
            when RED => DEBUG_BayerState <= "10";
        end case;

        case PixelState is
            when IDLE => DEBUG_PixelState <= "00";
            when PPROCESS => DEBUG_PixelState <= "01";
            when POUTPUT => DEBUG_PixelState <= "10";
            when PSKIP => DEBUG_PixelState <= "11";
        end case;

        case LineState is
            when LBUFFER => DEBUG_LineState <= "00";
            when LPROCESS => DEBUG_LineState <= "01";
            when LSKIP1 => DEBUG_LineState <= "10";
            when LSKIP2 => DEBUG_LineState <= "11";
        end case;
    end process;

    pBayerFSM: process(Clk, nReset)
    begin
        if nReset = '0' then
            BayerState <= IDLE;
            LineFIFOrreq <= '0';

            PixFIFOData <= (others => '0');
            PixelState <= IDLE;

            BlueCache <= (others => '0');
            GreenCache <= (others => '0');
        elsif rising_edge(Clk) then
            CamDataBuf <= CamData;
            case BayerState is
                when IDLE =>
                    if BayerActive = '0' then
                        BayerState <= IDLE;
                        LineFIFOrreq <= '0';
                    else
                        BayerState <= BLUE;
                        LineFIFOrreq <= '1';
                    end if;
                when BLUE =>
                    BlueCache <= CamDataBuf;
                    GreenCache <= LineFIFOData;
                    BayerState <= RED;
                when RED =>
                    PixFIFOData(15 DOWNTO 11) <= LineFIFOData;
                    PixFIFOData(4 DOWNTO 0) <= BlueCache;
                    PixFIFOData(10 DOWNTO 5) <= std_logic_vector(
                                                    unsigned('0' & GreenCache)
                                                  + unsigned(CamDataBuf)
                                                );
                    if BayerActive = '0' then
                        BayerState <= IDLE;
                        LineFIFOrreq <= '0';
                    else
                        BayerState <= BLUE;
                    end if;
            end case;

            PixFIFOwreq <= '0'; -- default
            case PixelState is
                when IDLE =>
                    if BayerActive = '0' then
                        PixelState <= IDLE;
                    else
                        PixelState <= PPROCESS;
                    end if;
                when PPROCESS =>
                    PixelState <= POUTPUT;
                when POUTPUT =>
                    PixFIFOwreq <= '1';
                    PixelState <= PSKIP;
                when PSKIP =>
                    PixelState <= IDLE;
            end case;

        end if;
    end process;

    BayerActive <= '1' when LValid = '1' and
                            FValid = '1' and
                            LineState = LPROCESS
                            else '0';

    LineFIFOwreq <= '1' when LValid = '1' and
                            FValid = '1' and
                            LineState = LBUFFER
                            else '0';

    pLineFSM: process(Clk, nReset)
    variable last_lvalid: std_logic;
    begin
        if nReset = '0' or FValid = '0' then
            last_lvalid := '0';
            LineState <= LBUFFER;
            LineFIFOclear <= '0';
        elsif rising_edge(Clk) then
            -- falling edge of LValid
            if (not LValid and last_lvalid) = '1' then
                LineFIFOclear <= '0'; -- default
                case LineState is
                    when LBUFFER => LineState <= LPROCESS;
                    when LPROCESS => LineState <= LSKIP1;
                    when LSKIP1 =>
                        LineFIFOclear <= '1';
                        LineState <= LSKIP2;
                    when LSKIP2 =>
                        LineState <= LBUFFER;
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
            PixFIFOaclr <= '0';
        elsif rising_edge(Clk) then
            -- rising edge of FValid
            if (FValid and not last_fvalid) = '1' then
                PixFIFOaclr <= '1'; -- clear PixFIFO
                AddressUpdate <= '1'; -- update image destination address
            else
                PixFIFOaclr <= '0';
                AddressUpdate <= '0';
            end if;
            last_fvalid := FValid;
        end if;
    end process;

end comp;
