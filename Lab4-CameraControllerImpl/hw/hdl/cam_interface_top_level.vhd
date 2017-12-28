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
	BurstCountMaster	 : OUT std_logic_vector(15 DOWNTO 0);
	WriteMaster	 		 : OUT std_logic;
	ByteEnableMaster	 : OUT std_logic_vector(2 DOWNTO 0);
	WriteDataMaster	 	 : OUT std_logic_vector(31 DOWNTO 0);
	
	-- Camera	
    GPIO_1_D5M_D       : IN    std_logic_vector(11 DOWNTO 0);
    GPIO_1_D5M_FVAL    : IN    std_logic;
    GPIO_1_D5M_LVAL    : IN    std_logic;
    GPIO_1_D5M_PIXCLK  : IN    std_logic;
    GPIO_1_D5M_RESET_N : OUT   std_logic;
 	GPIO_1_D5M_XCLKIN  : OUT   std_logic
	);
end entity cam_component;
	
architecture top_level of cam_component is
	
	--linefifo
	 signal LineFIFOrreq 	 : std_logic;
	 signal LineFIFOwreq 	 : std_logic;
	 signal LineFIFOData     : std_logic_vector(4 DOWNTO 0);
	 signal LineFIFOclear    : std_logic;
	 
	 --pixfifo
	 signal PixelDatawreq    : std_logic;
     signal PixelData        : std_logic_vector (15 DOWNTO 0);
     signal PixFIFOempty	 : std_logic;
     signal PixFIFOfull		 : std_logic;
     signal PixFIFOdataOut   : std_logic_vector (15 DOWNTO 0);
     signal PixFIFOrreq      : std_logic;
     
     --camera_interface to master 
     signal  AddressUpdate   :  std_logic;
    
     --slave to master
     signal ImageAddress	 : std_logic_vector (31 DOWNTO 0);
     
     --master to slave
     signal MasterIdle		: std_logic;
	
     -- to slave
     signal ImageEndIrq     : std_logic;
begin
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
			--CameraIfEnable => CameraIfEnable,
			--MasterEnable => MasterEnable,
			Camera_nReset => GPIO_1_D5M_RESET_N,
			--ImageStartIrq => ImageStartIrq,
			ImageEndIrq => ImageEndIrq
		);
	MASTER: entity work.master
		port map (
			main_clk => Clk,
			fifo_rdreq => PixFIFOrreq,
			fifo_empty => PixFIFOempty,
			fifo_full => PixFIFOfull,
			fifo_data_out => PixFIFOdataOut,
			av_waitreq => WaitreqMaster,
			av_address => AddressMaster,
			av_burst_count => BurstCountMaster,
			av_write => WriteMaster,
			av_byte_enable => ByteEnableMaster,
			av_write_data => WriteDataMaster,
			av_nreset => nReset,
			sv_image_address => ImageAddress,
			sv_address_update => AddressUpdate,
			burst_ready => MasterIdle
		);
	CAMERA_INTERFACE: entity work.camera_interface
		port map (
				Clk => GPIO_1_D5M_PIXCLK,
				nReset => nReset,
				CamData => GPIO_1_D5M_D(11 downto 7),
				LValid => GPIO_1_D5M_LVAL,
				FValid => GPIO_1_D5M_FVAL,
				LineFIFOrreq => LineFIFOrreq,
				LineFIFOwreq => LineFIFOwreq,
				LineFIFOData => LineFIFOData,
				LineFIFOclear => LineFIFOclear,
				PixelDatawreq => PixelDatawreq,
				PixelData => PixelData,
				AddressUpdate => AddressUpdate
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
			data    => PixelData,
			rdclk   => Clk,
			rdreq   => PixFIFOrreq,
			wrclk   => GPIO_1_D5M_PIXCLK,
			wrreq   => PixelDatawreq,
			q       => PixFIFOdataOut,
			rdempty => PixFIFOempty,
			wrfull  => PixFIFOfull
		);
	PLL: entity work.pll
		
			port map (
				refclk => Clk,
				rst => nReset,
				outclk_0 => GPIO_1_D5M_XCLKIN
				--locked => locked
		);
		
    pEndIrq: process(Clk, nReset)
    variable last_fvalid: std_logic;
    begin
        if nReset = '0' then
            last_fvalid := '0';
        elsif rising_edge(Clk) then
            -- falling edge of FValid
            if (not FValid and last_fvalid) = '1' then
                ImageEndIrq <= '1';
            else
                ImageEndIrq <= '0';
            end if;
            last_fvalid := FValid;
        end if;
    end process;

end architecture top_level;
	