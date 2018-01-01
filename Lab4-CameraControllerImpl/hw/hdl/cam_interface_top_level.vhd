library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cam_component is
	port(
	Clk                  : IN std_logic;
    nReset               : IN std_logic;

    -- Avalon Slave
    AddressSlave         : IN std_logic_vector (1 DOWNTO 0);
    ChipSelectSlave      : IN std_logic;
    ReadSlave            : IN std_logic;
    WriteSlave           : IN std_logic;
    ReadDataSlave        : OUT std_logic_vector (31 DOWNTO 0);
    WriteDataSlave       : IN std_logic_vector (31 DOWNTO 0);
    
    IrqSlave             : OUT std_logic;
    
    -- Avalon Master
	WaitreqMaster		 : IN std_logic;
	AddressMaster		 : OUT std_logic_vector(31 DOWNTO 0);
	BurstCountMaster	 : OUT std_logic_vector(3 DOWNTO 0);
	WriteMaster	 		 : OUT std_logic;
	ByteEnableMaster	 : OUT std_logic_vector(3 DOWNTO 0);
	WriteDataMaster	 	 : OUT std_logic_vector(31 DOWNTO 0);
	
	-- Camera	
    GPIO_1_D5M_D       : IN    std_logic_vector(11 DOWNTO 0);
    GPIO_1_D5M_FVAL    : IN    std_logic;
    GPIO_1_D5M_LVAL    : IN    std_logic;
    GPIO_1_D5M_PIXCLK  : IN    std_logic;
    GPIO_1_D5M_RESET_N : OUT   std_logic;

    -- Debug signals
   	DEBUG_LineFIFOrreq		: OUT std_logic;
	DEBUG_LineFIFOwreq		: OUT std_logic;
	DEBUG_LineFIFOclear		: OUT std_logic;
	DEBUG_LineFIFOData		: OUT std_logic_vector(4 DOWNTO 0);

	DEBUG_PixFIFOwreq		: OUT std_logic;
	DEBUG_PixFIFOaclr		: OUT std_logic;
    DEBUG_PixFIFOrreq		: OUT std_logic;
    DEBUG_PixFIFOrdusedw	: OUT std_logic_vector(4 DOWNTO 0);
    DEBUG_PixFIFOData		: OUT std_logic_vector (15 DOWNTO 0);

    DEBUG_PixelState        : OUT std_logic_vector (1 DOWNTO 0);
    DEBUG_LineState         : OUT std_logic_vector (1 DOWNTO 0);

	DEBUG_AddressUpdate		: OUT  std_logic;

	DEBUG_WaitreqMaster		: OUT std_logic;
	DEBUG_AddressMaster		: OUT std_logic_vector(31 DOWNTO 0);
	DEBUG_BurstCountMaster	: OUT std_logic_vector(3 DOWNTO 0);
	DEBUG_WriteMaster		: OUT std_logic;
	DEBUG_ByteEnableMaster	: OUT std_logic_vector(3 DOWNTO 0);
	DEBUG_WriteDataMaster	: OUT std_logic_vector(31 DOWNTO 0)
	);
end entity cam_component;
	
architecture top_level of cam_component is
	
	--linefifo
	 signal LineFIFOrreq 	 : std_logic;
	 signal LineFIFOwreq 	 : std_logic;
	 signal LineFIFOData     : std_logic_vector(4 DOWNTO 0);
	 signal LineFIFOclear    : std_logic;
	 
	 --pixfifo
	 signal PixFIFOaclr      : std_logic;
	 signal PixFIFOwreq      : std_logic;
     signal PixFIFOData      : std_logic_vector (15 DOWNTO 0);
     signal PixFIFOdataOut   : std_logic_vector (15 DOWNTO 0);
     signal PixFIFOrreq      : std_logic;
     signal PixFIFOrdusedw	 : std_logic_vector (4 DOWNTO 0);
     
     --camera_interface to master 
     signal  AddressUpdate   :  std_logic;
    
     --slave to master
     signal ImageAddress	 : std_logic_vector (31 DOWNTO 0);
     
     --master to slave
     signal MasterIdle		: std_logic;
	
     -- to slave
     signal ImageEndIrq     : std_logic;

    --slave to interface
    signal CameraIfEnable       : std_logic;

     -- Avalon Master
    signal iAddressMaster		: std_logic_vector(31 DOWNTO 0);
	signal iBurstCountMaster	: std_logic_vector(3 DOWNTO 0);
	signal iWriteMaster	 		: std_logic;
	signal iByteEnableMaster	: std_logic_vector(3 DOWNTO 0);
	signal iWriteDataMaster		: std_logic_vector(31 DOWNTO 0);
begin
	DEBUG_LineFIFOrreq <= LineFIFOrreq;
	DEBUG_LineFIFOwreq <= LineFIFOwreq;
	DEBUG_LineFIFOclear <= LineFIFOclear;
	DEBUG_LineFIFOData <= LineFIFOData;

	DEBUG_PixFIFOwreq <= PixFIFOwreq;
	DEBUG_PixFIFOaclr <= PixFIFOaclr;
	DEBUG_PixFIFOrreq <= PixFIFOrreq;
	DEBUG_PixFIFOrdusedw <= PixFIFOrdusedw;
	DEBUG_PixFIFOData <= PixFIFOData;
	
	DEBUG_AddressUpdate <= AddressUpdate;
	
	DEBUG_WaitreqMaster <= WaitreqMaster;
	DEBUG_AddressMaster <= iAddressMaster;
	DEBUG_BurstCountMaster <= iBurstCountMaster;
	DEBUG_WriteMaster <= iWriteMaster;
	DEBUG_ByteEnableMaster <= iByteEnableMaster;
	DEBUG_WriteDataMaster <= iWriteDataMaster;

	BurstCountMaster <= iBurstCountMaster;
	WriteMaster <= iWriteMaster;
	ByteEnableMaster <= iByteEnableMaster;

	SLAVE: entity work.camera_avalon_slave
		port map (
			Clk => Clk,
			nReset => nReset,
			Address => AddressSlave,
			ChipSelect => ChipSelectSlave,
			Read => ReadSlave,
			Write => WriteSlave,
			ReadData => ReadDataSlave,
			WriteData => WriteDataSlave,
			Irq => IrqSlave,
			ImageAddress => ImageAddress,
			CameraIfEnable => CameraIfEnable,
			--MasterEnable => MasterEnable,
			Camera_nReset => GPIO_1_D5M_RESET_N,
			--ImageStartIrq => ImageStartIrq,
			ImageEndIrq => ImageEndIrq
		);
	MASTER: entity work.master
		port map (
			main_clk => Clk,
			fifo_rdreq => PixFIFOrreq,
			fifo_rdusedw => PixFIFOrdusedw,
			fifo_data_out => PixFIFOdataOut,
			av_waitreq => WaitreqMaster,
			av_address => iAddressMaster,
			av_burst_count => iBurstCountMaster,
			av_write => iWriteMaster,
			av_byte_enable => iByteEnableMaster,
			av_write_data => iWriteDataMaster,
			av_nreset => nReset,
			sv_image_address => ImageAddress,
			sv_address_update => AddressUpdate,
			burst_ready => MasterIdle
		);
	CAMERA_INTERFACE: entity work.camera_interface
		port map (
				Clk => GPIO_1_D5M_PIXCLK,
				nReset => nReset,
				Enable => CameraIfEnable,
				CamData => GPIO_1_D5M_D(11 downto 7),
				LValid => GPIO_1_D5M_LVAL,
				FValid => GPIO_1_D5M_FVAL,
				LineFIFOrreq => LineFIFOrreq,
				LineFIFOwreq => LineFIFOwreq,
				LineFIFOData => LineFIFOData,
				LineFIFOclear => LineFIFOclear,
				PixFIFOwreq => PixFIFOwreq,
				PixFIFOData => PixFIFOData,
				PixFIFOaclr => PixFIFOaclr,
                AddressUpdate => AddressUpdate,
                DEBUG_PixelState => DEBUG_PixelState,
                DEBUG_LineState => DEBUG_LineState
			);
	LINEFIFO: entity work.linefifo
		port map(
			clock => Clk,
			data  => GPIO_1_D5M_D(11 downto 7),
			rdreq => LineFIFOrreq,
			sclr  => LineFIFOclear,
			wrreq => LineFIFOwreq,
			q     => LineFIFOData 
		);
	PIXFIFO: entity work.pixfifo
		port map(
			aclr	=> PixFIFOaclr,
			data    => PixFIFOData,
			rdclk   => Clk,
			rdreq   => PixFIFOrreq,
			wrclk   => GPIO_1_D5M_PIXCLK,
			wrreq   => PixFIFOwreq,
			q       => PixFIFOdataOut,
			rdusedw => PixFIFOrdusedw
		);
		
    pEndIrq: process(Clk, nReset)
    variable last_fvalid: std_logic;
    begin
        if nReset = '0' then
            last_fvalid := '0';
        elsif rising_edge(Clk) then
            -- falling edge of FValid
            if (not GPIO_1_D5M_FVAL and last_fvalid) = '1' then
                ImageEndIrq <= '1';
            else
                ImageEndIrq <= '0';
            end if;
            last_fvalid := GPIO_1_D5M_FVAL;
        end if;
    end process;

end architecture top_level;
	
