library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity camera_interface is
Port(
    Clk             : IN std_logic; -- Clk will be PIXCLK from Camera
    nReset          : IN std_logic;

    Enable          : IN std_logic; -- ignores camera input when not enabled

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
    DEBUG_PixelState      : OUT std_logic_vector (1 DOWNTO 0);
    DEBUG_LineState       : OUT std_logic_vector (1 DOWNTO 0)
);
End camera_interface;

Architecture comp of camera_interface is
    type PixelStateType is (
        IDLE,
        PBUFFER, -- receive BLUE and GREEN1 sensor values
        PWRITE   -- receive RED and GREEN2 sensor values
    );
    signal PixelState   : PixelStateType;
    signal PixelState_next : PixelStateType;

    type LineStateType is (
        IDLE,
        LBUFFER,
        PAUSE,
        LPROCESS
    );
    signal LineState    : LineStateType;
    signal LineState_next : LineStateType;

    signal  FrameStart : std_logic; -- is '1' when the interface received a frame start

    signal CamDataSample : std_logic_vector(4 DOWNTO 0);
    signal Red : std_logic_vector(4 DOWNTO 0);
    signal GreenCache : std_logic_vector(4 DOWNTO 0);
    signal Green : std_logic_vector(5 DOWNTO 0);
    signal Blue : std_logic_vector(4 DOWNTO 0);
begin
    PixFIFOData <= Red & Green & Blue;

    pDebug: process(PixelState, LineState)
    begin
        case PixelState is
            when IDLE => DEBUG_PixelState <= "00";
            when PBUFFER => DEBUG_PixelState <= "01";
            when PWRITE => DEBUG_PixelState <= "10";
        end case;

        case LineState is
            when IDLE => DEBUG_LineState <= "00";
            when LBUFFER => DEBUG_LineState <= "01";
            when PAUSE => DEBUG_LineState <= "10";
            when LPROCESS => DEBUG_LineState <= "11";
        end case;
    end process;

    -- FSM
    pStateTransition: process(Clk, nReset)
    begin
        if nReset = '0' then
            PixelState <= IDLE;
            LineState <= IDLE;
            CamDataSample <= (others => '0');
        elsif rising_edge(Clk) then
            PixelState <= PixelState_next;
            LineState <= LineState_next;
            CamDataSample <= CamData;
        end if;
    end process;

    pNextStateLogic: process(FValid, LValid, FrameStart, PixelState, LineState)
    begin
        -- default values
        LineFIFOwreq <= '0';
        LineFIFOrreq <= '0';
        PixFIFOwreq <= '0';
        PixelState_next <= PixelState;

        LineState_next <= LineState;
        if FValid = '1' and FrameStart = '1' then
            case LineState is
                when IDLE =>
                    if LValid = '1' then
                        LineState_next <= LBUFFER;
                        LineFIFOwreq <= '1';
                    end if;
                when LBUFFER =>
                    if LValid = '0' then
                        LineState_next <= PAUSE;
                    else
                        LineFIFOwreq <= '1';
                    end if;
                when PAUSE =>
                    if LValid = '1' then
                        LineState_next <= LPROCESS;
                    end if;
                when LPROCESS =>
                    if LValid = '0' then
                        LineState_next <= IDLE;
                    end if;
            end case;
        else
            LineState_next <= IDLE;
        end if;

        case PixelState is
            when IDLE =>
                Red <= (others => '0');
                Green <= (others => '0');
                GreenCache <= (others => '0');
                Blue <= (others => '0');

                LineFIFOrreq <= '0';

                -- rising edge of LValid with next state LPROCESS
                if LineState = PAUSE and LValid = '1' then
                    PixelState_next <= PBUFFER;
                end if;
            when PBUFFER => -- Blue & Green1
                LineFIFOrreq <= '1';
                Blue <= CamDataSample;
                GreenCache <= LineFIFOData;
                PixelState_next <= PWRITE;
            when PWRITE => -- Red & Green2
                LineFIFOrreq <= '1';
                PixFIFOwreq <= '1';
                Red <= LineFIFOData;
                Green <= std_logic_vector(unsigned('0' & GreenCache) + unsigned(CamDataSample));

                -- falling edge of LValid with next state IDLE
                if LineState = LPROCESS and LValid = '0' then
                    PixelState_next <= IDLE;
                else
                    PixelState_next <= PBUFFER;
                end if;
        end case;
    end process;

    pFrameStart: process(Clk, nReset)
    variable last_fvalid: std_logic;
    begin
        if nReset = '0' then
            last_fvalid := '1';
            FrameStart <= '0';
            AddressUpdate <= '0';
            PixFIFOaclr <= '0';
            LineFIFOclear <= '0';
        elsif rising_edge(Clk) then
            -- rising edge of FValid
            if (FValid and not last_fvalid) = '1' then
                if Enable = '1' then
                    FrameStart <= '1';
                end if;
                PixFIFOaclr <= '1'; -- clear PixFIFO
                LineFIFOclear <= '1'; -- clear LineFIFO
                AddressUpdate <= '1'; -- update image destination address
            else
                PixFIFOaclr <= '0';
                LineFIFOclear <= '0';
                AddressUpdate <= '0';
            end if;

            -- falling edge of FValid
            if (not FValid and last_fvalid) = '1' then
                FrameStart <= '0';
            end if;
            last_fvalid := FValid;
        end if;
    end process;

end comp;
