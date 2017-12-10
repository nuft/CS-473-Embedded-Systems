library ieee;
use ieee.std_logic_1164.all;

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
    PixelData       : OUT std_logic_vector (15 DOWNTO 0)
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
        IDLE,
        LBUFFER,
        LPROCESS,
        LSKIP
    );
    signal LineState    : LineStateType;
begin
    LineState <= LPROCESS; -- TODO: pLineFSM

    pBayerFSM: process(Clk, nReset)
    begin
        if nReset = '0' then
            BayerState <= IDLE;
            PixelData(1 DOWNTO 0) <= (others => '0');
        elsif rising_edge(Clk) then
            if LineState /= LPROCESS then
                BayerState <= IDLE;
            else
                case BayerState is
                    when IDLE =>
                        BayerState <= BLUE;
                    when BLUE =>
                        BayerState <= RED;
                    when RED =>
                        BayerState <= BLUE;
                end case;
            end if;
        end if;
    end process;

end comp;
