
module soc_system (
	cam_controller_d5m_d,
	cam_controller_d5m_fval,
	cam_controller_d5m_lval,
	cam_controller_d5m_pixclk,
	cam_controller_d5m_reset_n,
	cam_controller_debug_addressupdate,
	cam_controller_debug_linefifoclear,
	cam_controller_debug_linefiforr,
	cam_controller_debug_linefifowreq,
	cam_controller_debug_pixfiforreq,
	cam_controller_debug_burstcountmaster,
	cam_controller_debug_byteenablemaster,
	cam_controller_debug_waitreqmaster,
	cam_controller_debug_writemaster,
	cam_controller_debug_addressmaster,
	cam_controller_debug_pixfifoaclr,
	cam_controller_debug_pixfifordusedw,
	cam_controller_debug_pixfifowreq,
	cam_controller_debug_writedatamaster,
	cam_controller_debug_linefifodata,
	cam_controller_debug_pixfifodata,
	clk_clk,
	hps_0_ddr_mem_a,
	hps_0_ddr_mem_ba,
	hps_0_ddr_mem_ck,
	hps_0_ddr_mem_ck_n,
	hps_0_ddr_mem_cke,
	hps_0_ddr_mem_cs_n,
	hps_0_ddr_mem_ras_n,
	hps_0_ddr_mem_cas_n,
	hps_0_ddr_mem_we_n,
	hps_0_ddr_mem_reset_n,
	hps_0_ddr_mem_dq,
	hps_0_ddr_mem_dqs,
	hps_0_ddr_mem_dqs_n,
	hps_0_ddr_mem_odt,
	hps_0_ddr_mem_dm,
	hps_0_ddr_oct_rzqin,
	hps_0_io_hps_io_emac1_inst_TX_CLK,
	hps_0_io_hps_io_emac1_inst_TXD0,
	hps_0_io_hps_io_emac1_inst_TXD1,
	hps_0_io_hps_io_emac1_inst_TXD2,
	hps_0_io_hps_io_emac1_inst_TXD3,
	hps_0_io_hps_io_emac1_inst_RXD0,
	hps_0_io_hps_io_emac1_inst_MDIO,
	hps_0_io_hps_io_emac1_inst_MDC,
	hps_0_io_hps_io_emac1_inst_RX_CTL,
	hps_0_io_hps_io_emac1_inst_TX_CTL,
	hps_0_io_hps_io_emac1_inst_RX_CLK,
	hps_0_io_hps_io_emac1_inst_RXD1,
	hps_0_io_hps_io_emac1_inst_RXD2,
	hps_0_io_hps_io_emac1_inst_RXD3,
	hps_0_io_hps_io_sdio_inst_CMD,
	hps_0_io_hps_io_sdio_inst_D0,
	hps_0_io_hps_io_sdio_inst_D1,
	hps_0_io_hps_io_sdio_inst_CLK,
	hps_0_io_hps_io_sdio_inst_D2,
	hps_0_io_hps_io_sdio_inst_D3,
	hps_0_io_hps_io_usb1_inst_D0,
	hps_0_io_hps_io_usb1_inst_D1,
	hps_0_io_hps_io_usb1_inst_D2,
	hps_0_io_hps_io_usb1_inst_D3,
	hps_0_io_hps_io_usb1_inst_D4,
	hps_0_io_hps_io_usb1_inst_D5,
	hps_0_io_hps_io_usb1_inst_D6,
	hps_0_io_hps_io_usb1_inst_D7,
	hps_0_io_hps_io_usb1_inst_CLK,
	hps_0_io_hps_io_usb1_inst_STP,
	hps_0_io_hps_io_usb1_inst_DIR,
	hps_0_io_hps_io_usb1_inst_NXT,
	hps_0_io_hps_io_spim1_inst_CLK,
	hps_0_io_hps_io_spim1_inst_MOSI,
	hps_0_io_hps_io_spim1_inst_MISO,
	hps_0_io_hps_io_spim1_inst_SS0,
	hps_0_io_hps_io_uart0_inst_RX,
	hps_0_io_hps_io_uart0_inst_TX,
	hps_0_io_hps_io_i2c0_inst_SDA,
	hps_0_io_hps_io_i2c0_inst_SCL,
	hps_0_io_hps_io_i2c1_inst_SDA,
	hps_0_io_hps_io_i2c1_inst_SCL,
	hps_0_io_hps_io_gpio_inst_GPIO09,
	hps_0_io_hps_io_gpio_inst_GPIO35,
	hps_0_io_hps_io_gpio_inst_GPIO40,
	hps_0_io_hps_io_gpio_inst_GPIO53,
	hps_0_io_hps_io_gpio_inst_GPIO54,
	hps_0_io_hps_io_gpio_inst_GPIO61,
	i2c_0_i2c_scl,
	i2c_0_i2c_sda,
	pio_leds_external_connection_export,
	pll_0_outclk0_clk,
	reset_reset_n);	

	input	[11:0]	cam_controller_d5m_d;
	input		cam_controller_d5m_fval;
	input		cam_controller_d5m_lval;
	input		cam_controller_d5m_pixclk;
	output		cam_controller_d5m_reset_n;
	output		cam_controller_debug_addressupdate;
	output		cam_controller_debug_linefifoclear;
	output		cam_controller_debug_linefiforr;
	output		cam_controller_debug_linefifowreq;
	output		cam_controller_debug_pixfiforreq;
	output	[3:0]	cam_controller_debug_burstcountmaster;
	output	[3:0]	cam_controller_debug_byteenablemaster;
	output		cam_controller_debug_waitreqmaster;
	output		cam_controller_debug_writemaster;
	output	[31:0]	cam_controller_debug_addressmaster;
	output		cam_controller_debug_pixfifoaclr;
	output	[4:0]	cam_controller_debug_pixfifordusedw;
	output		cam_controller_debug_pixfifowreq;
	output	[31:0]	cam_controller_debug_writedatamaster;
	output	[4:0]	cam_controller_debug_linefifodata;
	output	[15:0]	cam_controller_debug_pixfifodata;
	input		clk_clk;
	output	[14:0]	hps_0_ddr_mem_a;
	output	[2:0]	hps_0_ddr_mem_ba;
	output		hps_0_ddr_mem_ck;
	output		hps_0_ddr_mem_ck_n;
	output		hps_0_ddr_mem_cke;
	output		hps_0_ddr_mem_cs_n;
	output		hps_0_ddr_mem_ras_n;
	output		hps_0_ddr_mem_cas_n;
	output		hps_0_ddr_mem_we_n;
	output		hps_0_ddr_mem_reset_n;
	inout	[31:0]	hps_0_ddr_mem_dq;
	inout	[3:0]	hps_0_ddr_mem_dqs;
	inout	[3:0]	hps_0_ddr_mem_dqs_n;
	output		hps_0_ddr_mem_odt;
	output	[3:0]	hps_0_ddr_mem_dm;
	input		hps_0_ddr_oct_rzqin;
	output		hps_0_io_hps_io_emac1_inst_TX_CLK;
	output		hps_0_io_hps_io_emac1_inst_TXD0;
	output		hps_0_io_hps_io_emac1_inst_TXD1;
	output		hps_0_io_hps_io_emac1_inst_TXD2;
	output		hps_0_io_hps_io_emac1_inst_TXD3;
	input		hps_0_io_hps_io_emac1_inst_RXD0;
	inout		hps_0_io_hps_io_emac1_inst_MDIO;
	output		hps_0_io_hps_io_emac1_inst_MDC;
	input		hps_0_io_hps_io_emac1_inst_RX_CTL;
	output		hps_0_io_hps_io_emac1_inst_TX_CTL;
	input		hps_0_io_hps_io_emac1_inst_RX_CLK;
	input		hps_0_io_hps_io_emac1_inst_RXD1;
	input		hps_0_io_hps_io_emac1_inst_RXD2;
	input		hps_0_io_hps_io_emac1_inst_RXD3;
	inout		hps_0_io_hps_io_sdio_inst_CMD;
	inout		hps_0_io_hps_io_sdio_inst_D0;
	inout		hps_0_io_hps_io_sdio_inst_D1;
	output		hps_0_io_hps_io_sdio_inst_CLK;
	inout		hps_0_io_hps_io_sdio_inst_D2;
	inout		hps_0_io_hps_io_sdio_inst_D3;
	inout		hps_0_io_hps_io_usb1_inst_D0;
	inout		hps_0_io_hps_io_usb1_inst_D1;
	inout		hps_0_io_hps_io_usb1_inst_D2;
	inout		hps_0_io_hps_io_usb1_inst_D3;
	inout		hps_0_io_hps_io_usb1_inst_D4;
	inout		hps_0_io_hps_io_usb1_inst_D5;
	inout		hps_0_io_hps_io_usb1_inst_D6;
	inout		hps_0_io_hps_io_usb1_inst_D7;
	input		hps_0_io_hps_io_usb1_inst_CLK;
	output		hps_0_io_hps_io_usb1_inst_STP;
	input		hps_0_io_hps_io_usb1_inst_DIR;
	input		hps_0_io_hps_io_usb1_inst_NXT;
	output		hps_0_io_hps_io_spim1_inst_CLK;
	output		hps_0_io_hps_io_spim1_inst_MOSI;
	input		hps_0_io_hps_io_spim1_inst_MISO;
	output		hps_0_io_hps_io_spim1_inst_SS0;
	input		hps_0_io_hps_io_uart0_inst_RX;
	output		hps_0_io_hps_io_uart0_inst_TX;
	inout		hps_0_io_hps_io_i2c0_inst_SDA;
	inout		hps_0_io_hps_io_i2c0_inst_SCL;
	inout		hps_0_io_hps_io_i2c1_inst_SDA;
	inout		hps_0_io_hps_io_i2c1_inst_SCL;
	inout		hps_0_io_hps_io_gpio_inst_GPIO09;
	inout		hps_0_io_hps_io_gpio_inst_GPIO35;
	inout		hps_0_io_hps_io_gpio_inst_GPIO40;
	inout		hps_0_io_hps_io_gpio_inst_GPIO53;
	inout		hps_0_io_hps_io_gpio_inst_GPIO54;
	inout		hps_0_io_hps_io_gpio_inst_GPIO61;
	inout		i2c_0_i2c_scl;
	inout		i2c_0_i2c_sda;
	output	[7:0]	pio_leds_external_connection_export;
	output		pll_0_outclk0_clk;
	input		reset_reset_n;
endmodule
