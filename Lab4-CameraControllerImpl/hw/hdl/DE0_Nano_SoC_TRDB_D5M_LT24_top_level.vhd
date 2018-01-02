-- #############################################################################
-- DE0_Nano_SoC_TRDB_D5M_LT24_top_level.vhd
--
-- BOARD         : DE0-Nano-SoC from Terasic
-- Author        : Sahand Kashani-Akhavan from Terasic documentation
-- Revision      : 1.3
-- Creation date : 11/06/2015
--
-- Syntax Rule : GROUP_NAME_N[bit]
--
-- GROUP : specify a particular interface (ex: SDR_)
-- NAME  : signal name (ex: CONFIG, D, ...)
-- bit   : signal index
-- _N    : to specify an active-low signal
-- #############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE0_Nano_SoC_TRDB_D5M_LT24_top_level is
    port(
        -- ADC
        ADC_CONVST : out std_logic;
        ADC_SCK    : out std_logic;
        ADC_SDI    : out std_logic;
        ADC_SDO    : in  std_logic;

        -- ARDUINO
        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic;

        -- CLOCK
        FPGA_CLK1_50 : in std_logic;
        FPGA_CLK2_50 : in std_logic;
        FPGA_CLK3_50 : in std_logic;

        -- KEY
        KEY_N : in std_logic_vector(1 downto 0);

        -- LED
        LED : out std_logic_vector(7 downto 0);

        -- SW
        SW : in std_logic_vector(3 downto 0);

        -- GPIO_0
        GPIO_0_LT24_ADC_BUSY     : in  std_logic;
        GPIO_0_LT24_ADC_CS_N     : out std_logic;
        GPIO_0_LT24_ADC_DCLK     : out std_logic;
        GPIO_0_LT24_ADC_DIN      : out std_logic;
        GPIO_0_LT24_ADC_DOUT     : in  std_logic;
        GPIO_0_LT24_ADC_PENIRQ_N : in  std_logic;
        GPIO_0_LT24_CS_N         : out std_logic;
        GPIO_0_LT24_D            : out std_logic_vector(15 downto 0);
        GPIO_0_LT24_LCD_ON       : out std_logic;
        GPIO_0_LT24_RD_N         : out std_logic;
        GPIO_0_LT24_RESET_N      : out std_logic;
        GPIO_0_LT24_RS           : out std_logic;
        GPIO_0_LT24_WR_N         : out std_logic;

        -- GPIO_1
        GPIO_1_D5M_D       : in    std_logic_vector(11 downto 0);
        GPIO_1_D5M_FVAL    : in    std_logic;
        GPIO_1_D5M_LVAL    : in    std_logic;
        GPIO_1_D5M_PIXCLK  : in    std_logic;
        GPIO_1_D5M_RESET_N : out   std_logic;
        GPIO_1_D5M_SCLK    : inout std_logic;
        GPIO_1_D5M_SDATA   : inout std_logic;
        GPIO_1_D5M_STROBE  : in    std_logic;
        GPIO_1_D5M_TRIGGER : out   std_logic;
        GPIO_1_D5M_XCLKIN  : out   std_logic;

        -- HPS
        HPS_CONV_USB_N   : inout std_logic;
        HPS_DDR3_ADDR    : out   std_logic_vector(14 downto 0);
        HPS_DDR3_BA      : out   std_logic_vector(2 downto 0);
        HPS_DDR3_CAS_N   : out   std_logic;
        HPS_DDR3_CK_N    : out   std_logic;
        HPS_DDR3_CK_P    : out   std_logic;
        HPS_DDR3_CKE     : out   std_logic;
        HPS_DDR3_CS_N    : out   std_logic;
        HPS_DDR3_DM      : out   std_logic_vector(3 downto 0);
        HPS_DDR3_DQ      : inout std_logic_vector(31 downto 0);
        HPS_DDR3_DQS_N   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_ODT     : out   std_logic;
        HPS_DDR3_RAS_N   : out   std_logic;
        HPS_DDR3_RESET_N : out   std_logic;
        HPS_DDR3_RZQ     : in    std_logic;
        HPS_DDR3_WE_N    : out   std_logic;
        HPS_ENET_GTX_CLK : out   std_logic;
        HPS_ENET_INT_N   : inout std_logic;
        HPS_ENET_MDC     : out   std_logic;
        HPS_ENET_MDIO    : inout std_logic;
        HPS_ENET_RX_CLK  : in    std_logic;
        HPS_ENET_RX_DATA : in    std_logic_vector(3 downto 0);
        HPS_ENET_RX_DV   : in    std_logic;
        HPS_ENET_TX_DATA : out   std_logic_vector(3 downto 0);
        HPS_ENET_TX_EN   : out   std_logic;
        HPS_GSENSOR_INT  : inout std_logic;
        HPS_I2C0_SCLK    : inout std_logic;
        HPS_I2C0_SDAT    : inout std_logic;
        HPS_I2C1_SCLK    : inout std_logic;
        HPS_I2C1_SDAT    : inout std_logic;
        HPS_KEY_N        : inout std_logic;
        HPS_LED          : inout std_logic;
        HPS_LTC_GPIO     : inout std_logic;
        HPS_SD_CLK       : out   std_logic;
        HPS_SD_CMD       : inout std_logic;
        HPS_SD_DATA      : inout std_logic_vector(3 downto 0);
        HPS_SPIM_CLK     : out   std_logic;
        HPS_SPIM_MISO    : in    std_logic;
        HPS_SPIM_MOSI    : out   std_logic;
        HPS_SPIM_SS      : inout std_logic;
        HPS_UART_RX      : in    std_logic;
        HPS_UART_TX      : out   std_logic;
        HPS_USB_CLKOUT   : in    std_logic;
        HPS_USB_DATA     : inout std_logic_vector(7 downto 0);
        HPS_USB_DIR      : in    std_logic;
        HPS_USB_NXT      : in    std_logic;
        HPS_USB_STP      : out   std_logic
    );
end entity DE0_Nano_SoC_TRDB_D5M_LT24_top_level;

architecture rtl of DE0_Nano_SoC_TRDB_D5M_LT24_top_level is
    
    signal INT_cam_controller_debug_addressupdate    : std_logic;                                        -- debug_addressupdate
    signal INT_cam_controller_debug_linefifoclear    : std_logic;                                        -- debug_linefifoclear
    signal INT_cam_controller_debug_linefiforr       : std_logic;                                        -- debug_linefiforr
    signal INT_cam_controller_debug_linefifowreq     : std_logic;                                        -- debug_linefifowreq
    signal INT_cam_controller_debug_pixfiforreq      : std_logic;                                        -- debug_pixfiforreq
    signal INT_cam_controller_debug_burstcountmaster : std_logic_vector(3 downto 0);                     -- debug_burstcountmaster
    signal INT_cam_controller_debug_byteenablemaster : std_logic_vector(3 downto 0);                     -- debug_byteenablemaster
    signal INT_cam_controller_debug_waitreqmaster    : std_logic;                                        -- debug_waitreqmaster
    signal INT_cam_controller_debug_writemaster      : std_logic;                                        -- debug_writemaster
    signal INT_cam_controller_debug_addressmaster    : std_logic_vector(31 downto 0);                    -- debug_addressmaster
    signal INT_cam_controller_debug_pixfifoaclr      : std_logic;                                        -- debug_pixfifoaclr
    signal INT_cam_controller_debug_pixfifordusedw   : std_logic_vector(4 downto 0);                     -- debug_pixfifordusedw
    signal INT_cam_controller_debug_pixfifowreq      : std_logic;                                        -- debug_pixfifowreq
    signal INT_cam_controller_debug_writedatamaster  : std_logic_vector(31 downto 0);                    -- debug_writedatamaster
    signal INT_cam_controller_debug_linefifodata     : std_logic_vector(4 downto 0);                     -- debug_linefifodata
    signal INT_cam_controller_debug_pixfifodata      : std_logic_vector(15 downto 0);                    -- debug_pixfifodata
    signal INT_cam_controller_debug_linestate        : std_logic_vector(1 downto 0);                     -- debug_linestate
    signal INT_cam_controller_debug_pixelstate       : std_logic_vector(1 downto 0);                     -- debug_pixelstate
    signal INT_cam_controller_debug_offset           : std_logic_vector(31 downto 0);                    -- debug_offset
    signal INT_cam_controller_debug_pixfifodataout   : std_logic_vector(15 downto 0);                    -- debug_pixfifodataout
    signal DEBUG_addr_msb_is_not_zero: std_logic;
    signal DEBUG_offset_msb_is_not_zero: std_logic;

    component soc_system is
        port (
            clk_clk                             : in    std_logic                     := 'X';
            reset_reset_n                       : in    std_logic                     := 'X';
            hps_0_ddr_mem_a                     : out   std_logic_vector(14 downto 0);
            hps_0_ddr_mem_ba                    : out   std_logic_vector(2 downto 0);
            hps_0_ddr_mem_ck                    : out   std_logic;
            hps_0_ddr_mem_ck_n                  : out   std_logic;
            hps_0_ddr_mem_cke                   : out   std_logic;
            hps_0_ddr_mem_cs_n                  : out   std_logic;
            hps_0_ddr_mem_ras_n                 : out   std_logic;
            hps_0_ddr_mem_cas_n                 : out   std_logic;
            hps_0_ddr_mem_we_n                  : out   std_logic;
            hps_0_ddr_mem_reset_n               : out   std_logic;
            hps_0_ddr_mem_dq                    : inout std_logic_vector(31 downto 0) := (others => 'X');
            hps_0_ddr_mem_dqs                   : inout std_logic_vector(3 downto 0)  := (others => 'X');
            hps_0_ddr_mem_dqs_n                 : inout std_logic_vector(3 downto 0)  := (others => 'X');
            hps_0_ddr_mem_odt                   : out   std_logic;
            hps_0_ddr_mem_dm                    : out   std_logic_vector(3 downto 0);
            hps_0_ddr_oct_rzqin                 : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_TX_CLK   : out   std_logic;
            hps_0_io_hps_io_emac1_inst_TX_CTL   : out   std_logic;
            hps_0_io_hps_io_emac1_inst_TXD0     : out   std_logic;
            hps_0_io_hps_io_emac1_inst_TXD1     : out   std_logic;
            hps_0_io_hps_io_emac1_inst_TXD2     : out   std_logic;
            hps_0_io_hps_io_emac1_inst_TXD3     : out   std_logic;
            hps_0_io_hps_io_emac1_inst_RX_CLK   : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_RX_CTL   : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_RXD0     : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_RXD1     : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_RXD2     : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_RXD3     : in    std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_MDIO     : inout std_logic                     := 'X';
            hps_0_io_hps_io_emac1_inst_MDC      : out   std_logic;
            hps_0_io_hps_io_sdio_inst_CLK       : out   std_logic;
            hps_0_io_hps_io_sdio_inst_CMD       : inout std_logic                     := 'X';
            hps_0_io_hps_io_sdio_inst_D0        : inout std_logic                     := 'X';
            hps_0_io_hps_io_sdio_inst_D1        : inout std_logic                     := 'X';
            hps_0_io_hps_io_sdio_inst_D2        : inout std_logic                     := 'X';
            hps_0_io_hps_io_sdio_inst_D3        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_CLK       : in    std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_STP       : out   std_logic;
            hps_0_io_hps_io_usb1_inst_DIR       : in    std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_NXT       : in    std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D0        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D1        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D2        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D3        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D4        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D5        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D6        : inout std_logic                     := 'X';
            hps_0_io_hps_io_usb1_inst_D7        : inout std_logic                     := 'X';
            hps_0_io_hps_io_spim1_inst_CLK      : out   std_logic;
            hps_0_io_hps_io_spim1_inst_MOSI     : out   std_logic;
            hps_0_io_hps_io_spim1_inst_MISO     : in    std_logic                     := 'X';
            hps_0_io_hps_io_spim1_inst_SS0      : out   std_logic;
            hps_0_io_hps_io_uart0_inst_RX       : in    std_logic                     := 'X';
            hps_0_io_hps_io_uart0_inst_TX       : out   std_logic;
            hps_0_io_hps_io_i2c0_inst_SDA       : inout std_logic                     := 'X';
            hps_0_io_hps_io_i2c0_inst_SCL       : inout std_logic                     := 'X';
            hps_0_io_hps_io_i2c1_inst_SDA       : inout std_logic                     := 'X';
            hps_0_io_hps_io_i2c1_inst_SCL       : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO09    : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO35    : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO40    : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO53    : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO54    : inout std_logic                     := 'X';
            hps_0_io_hps_io_gpio_inst_GPIO61    : inout std_logic                     := 'X';
            pio_leds_external_connection_export : out   std_logic_vector(7 downto 0);
            i2c_0_i2c_scl                            : inout std_logic                     := 'X';             -- scl
            i2c_0_i2c_sda                            : inout std_logic                     := 'X';             -- sda
            cam_controller_d5m_d                  : in    std_logic_vector(11 downto 0) := (others => 'X'); -- d5m_d
            cam_controller_d5m_fval               : in    std_logic                     := 'X';             -- d5m_fval
            cam_controller_d5m_lval               : in    std_logic                     := 'X';             -- d5m_lval
            cam_controller_d5m_pixclk             : in    std_logic                     := 'X';             -- d5m_pixclk
            cam_controller_d5m_reset_n            : out   std_logic;                                        -- d5m_reset_n
            cam_controller_debug_addressupdate    : out   std_logic;                                        -- debug_addressupdate
            cam_controller_debug_linefifoclear    : out   std_logic;                                        -- debug_linefifoclear
            cam_controller_debug_linefiforr       : out   std_logic;                                        -- debug_linefiforr
            cam_controller_debug_linefifowreq     : out   std_logic;                                        -- debug_linefifowreq
            cam_controller_debug_pixfiforreq      : out   std_logic;                                        -- debug_pixfiforreq
            cam_controller_debug_burstcountmaster : out   std_logic_vector(3 downto 0);                     -- debug_burstcountmaster
            cam_controller_debug_byteenablemaster : out   std_logic_vector(3 downto 0);                     -- debug_byteenablemaster
            cam_controller_debug_waitreqmaster    : out   std_logic;                                        -- debug_waitreqmaster
            cam_controller_debug_writemaster      : out   std_logic;                                        -- debug_writemaster
            cam_controller_debug_addressmaster    : out   std_logic_vector(31 downto 0);                    -- debug_addressmaster
            cam_controller_debug_pixfifoaclr      : out   std_logic;                                        -- debug_pixfifoaclr
            cam_controller_debug_pixfifordusedw   : out   std_logic_vector(4 downto 0);                     -- debug_pixfifordusedw
            cam_controller_debug_pixfifowreq      : out   std_logic;                                        -- debug_pixfifowreq
            cam_controller_debug_writedatamaster  : out   std_logic_vector(31 downto 0);                    -- debug_writedatamaster
            cam_controller_debug_linefifodata     : out   std_logic_vector(4 downto 0);                     -- debug_linefifodata
            cam_controller_debug_pixfifodata      : out   std_logic_vector(15 downto 0);                    -- debug_pixfifodata
            cam_controller_debug_linestate        : out   std_logic_vector(1 downto 0);                     -- debug_linestate
            cam_controller_debug_pixelstate       : out   std_logic_vector(1 downto 0);                     -- debug_pixelstate
            cam_controller_debug_offset           : out   std_logic_vector(31 downto 0);                    -- debug_offset
            cam_controller_debug_pixfifodataout   : out   std_logic_vector(15 downto 0);                    -- debug_pixfifodataout
            pll_0_outclk0_clk                   : out   std_logic                                         -- clk
        );
    end component soc_system;

begin

    u0 : component soc_system
    port map(
        clk_clk                             => FPGA_CLK1_50,
        hps_0_ddr_mem_a                     => HPS_DDR3_ADDR,
        hps_0_ddr_mem_ba                    => HPS_DDR3_BA,
        hps_0_ddr_mem_ck                    => HPS_DDR3_CK_P,
        hps_0_ddr_mem_ck_n                  => HPS_DDR3_CK_N,
        hps_0_ddr_mem_cke                   => HPS_DDR3_CKE,
        hps_0_ddr_mem_cs_n                  => HPS_DDR3_CS_N,
        hps_0_ddr_mem_ras_n                 => HPS_DDR3_RAS_N,
        hps_0_ddr_mem_cas_n                 => HPS_DDR3_CAS_N,
        hps_0_ddr_mem_we_n                  => HPS_DDR3_WE_N,
        hps_0_ddr_mem_reset_n               => HPS_DDR3_RESET_N,
        hps_0_ddr_mem_dq                    => HPS_DDR3_DQ,
        hps_0_ddr_mem_dqs                   => HPS_DDR3_DQS_P,
        hps_0_ddr_mem_dqs_n                 => HPS_DDR3_DQS_N,
        hps_0_ddr_mem_odt                   => HPS_DDR3_ODT,
        hps_0_ddr_mem_dm                    => HPS_DDR3_DM,
        hps_0_ddr_oct_rzqin                 => HPS_DDR3_RZQ,
        hps_0_io_hps_io_emac1_inst_TX_CLK   => HPS_ENET_GTX_CLK,
        hps_0_io_hps_io_emac1_inst_TX_CTL   => HPS_ENET_TX_EN,
        hps_0_io_hps_io_emac1_inst_TXD0     => HPS_ENET_TX_DATA(0),
        hps_0_io_hps_io_emac1_inst_TXD1     => HPS_ENET_TX_DATA(1),
        hps_0_io_hps_io_emac1_inst_TXD2     => HPS_ENET_TX_DATA(2),
        hps_0_io_hps_io_emac1_inst_TXD3     => HPS_ENET_TX_DATA(3),
        hps_0_io_hps_io_emac1_inst_RX_CLK   => HPS_ENET_RX_CLK,
        hps_0_io_hps_io_emac1_inst_RX_CTL   => HPS_ENET_RX_DV,
        hps_0_io_hps_io_emac1_inst_RXD0     => HPS_ENET_RX_DATA(0),
        hps_0_io_hps_io_emac1_inst_RXD1     => HPS_ENET_RX_DATA(1),
        hps_0_io_hps_io_emac1_inst_RXD2     => HPS_ENET_RX_DATA(2),
        hps_0_io_hps_io_emac1_inst_RXD3     => HPS_ENET_RX_DATA(3),
        hps_0_io_hps_io_emac1_inst_MDIO     => HPS_ENET_MDIO,
        hps_0_io_hps_io_emac1_inst_MDC      => HPS_ENET_MDC,
        hps_0_io_hps_io_sdio_inst_CLK       => HPS_SD_CLK,
        hps_0_io_hps_io_sdio_inst_CMD       => HPS_SD_CMD,
        hps_0_io_hps_io_sdio_inst_D0        => HPS_SD_DATA(0),
        hps_0_io_hps_io_sdio_inst_D1        => HPS_SD_DATA(1),
        hps_0_io_hps_io_sdio_inst_D2        => HPS_SD_DATA(2),
        hps_0_io_hps_io_sdio_inst_D3        => HPS_SD_DATA(3),
        hps_0_io_hps_io_usb1_inst_CLK       => HPS_USB_CLKOUT,
        hps_0_io_hps_io_usb1_inst_STP       => HPS_USB_STP,
        hps_0_io_hps_io_usb1_inst_DIR       => HPS_USB_DIR,
        hps_0_io_hps_io_usb1_inst_NXT       => HPS_USB_NXT,
        hps_0_io_hps_io_usb1_inst_D0        => HPS_USB_DATA(0),
        hps_0_io_hps_io_usb1_inst_D1        => HPS_USB_DATA(1),
        hps_0_io_hps_io_usb1_inst_D2        => HPS_USB_DATA(2),
        hps_0_io_hps_io_usb1_inst_D3        => HPS_USB_DATA(3),
        hps_0_io_hps_io_usb1_inst_D4        => HPS_USB_DATA(4),
        hps_0_io_hps_io_usb1_inst_D5        => HPS_USB_DATA(5),
        hps_0_io_hps_io_usb1_inst_D6        => HPS_USB_DATA(6),
        hps_0_io_hps_io_usb1_inst_D7        => HPS_USB_DATA(7),
        hps_0_io_hps_io_spim1_inst_CLK      => HPS_SPIM_CLK,
        hps_0_io_hps_io_spim1_inst_MOSI     => HPS_SPIM_MOSI,
        hps_0_io_hps_io_spim1_inst_MISO     => HPS_SPIM_MISO,
        hps_0_io_hps_io_spim1_inst_SS0      => HPS_SPIM_SS,
        hps_0_io_hps_io_uart0_inst_RX       => HPS_UART_RX,
        hps_0_io_hps_io_uart0_inst_TX       => HPS_UART_TX,
        hps_0_io_hps_io_i2c0_inst_SDA       => HPS_I2C0_SDAT,
        hps_0_io_hps_io_i2c0_inst_SCL       => HPS_I2C0_SCLK,
        hps_0_io_hps_io_i2c1_inst_SDA       => HPS_I2C1_SDAT,
        hps_0_io_hps_io_i2c1_inst_SCL       => HPS_I2C1_SCLK,
        hps_0_io_hps_io_gpio_inst_GPIO09    => HPS_CONV_USB_N,
        hps_0_io_hps_io_gpio_inst_GPIO35    => HPS_ENET_INT_N,
        hps_0_io_hps_io_gpio_inst_GPIO40    => HPS_LTC_GPIO,
        hps_0_io_hps_io_gpio_inst_GPIO53    => HPS_LED,
        hps_0_io_hps_io_gpio_inst_GPIO54    => HPS_KEY_N,
        hps_0_io_hps_io_gpio_inst_GPIO61    => HPS_GSENSOR_INT,
        pio_leds_external_connection_export => LED,
        reset_reset_n                       => KEY_N(0),                            --                        reset.reset_n
        i2c_0_i2c_scl                       => GPIO_1_D5M_SCLK,                            --                    i2c_0_i2c.scl
        i2c_0_i2c_sda                       => GPIO_1_D5M_SDATA,                            --                             .sda

        cam_controller_d5m_d                => GPIO_1_D5M_D,                --               cam_controller.d5m_d
        cam_controller_d5m_fval             => GPIO_1_D5M_FVAL,             --                             .d5m_fval
        cam_controller_d5m_lval             => GPIO_1_D5M_LVAL,             --                             .d5m_lval
        cam_controller_d5m_pixclk           => GPIO_1_D5M_PIXCLK,           --                             .d5m_pixclk
        cam_controller_d5m_reset_n          => GPIO_1_D5M_RESET_N,          --                             .d5m_reset_n
        
        cam_controller_debug_pixfifoaclr      => INT_cam_controller_debug_pixfifoaclr,      --                             .debug_pixfifoaclr
        cam_controller_debug_pixfifordusedw   => INT_cam_controller_debug_pixfifordusedw,   --                             .debug_pixfifordusedw
        cam_controller_debug_pixfifowreq      => INT_cam_controller_debug_pixfifowreq,      --                             .debug_pixfifowreq
        cam_controller_debug_pixfiforreq      => INT_cam_controller_debug_pixfiforreq,      --                             .debug_pixfiforreq
        cam_controller_debug_addressupdate    => INT_cam_controller_debug_addressupdate,    --                             .debug_addressupdate
        cam_controller_debug_linefifoclear    => INT_cam_controller_debug_linefifoclear,    --                             .debug_linefifoclear
        cam_controller_debug_linefiforr       => INT_cam_controller_debug_linefiforr,       --                             .debug_linefiforr
        cam_controller_debug_linefifowreq     => INT_cam_controller_debug_linefifowreq,     --                             .debug_linefifowreq
        cam_controller_debug_burstcountmaster => INT_cam_controller_debug_burstcountmaster, --                             .debug_burstcountmaster
        cam_controller_debug_byteenablemaster => INT_cam_controller_debug_byteenablemaster, --                             .debug_byteenablemaster
        cam_controller_debug_waitreqmaster    => INT_cam_controller_debug_waitreqmaster,    --                             .debug_waitreqmaster
        cam_controller_debug_writemaster      => INT_cam_controller_debug_writemaster,      --                             .debug_writemaster
        cam_controller_debug_addressmaster    => INT_cam_controller_debug_addressmaster,    --                             .debug_addressmaster
        cam_controller_debug_writedatamaster  => INT_cam_controller_debug_writedatamaster,  --                             .debug_writedatamaster
        cam_controller_debug_linefifodata     => INT_cam_controller_debug_linefifodata,     --                             .debug_linefifodata
        cam_controller_debug_pixfifodata      => INT_cam_controller_debug_pixfifodata,      --                             .debug_pixfifodata
        cam_controller_debug_linestate        => INT_cam_controller_debug_linestate,        --                             .debug_linestate
        cam_controller_debug_pixelstate       => INT_cam_controller_debug_pixelstate,       --                             .debug_pixelstate
        cam_controller_debug_offset           => INT_cam_controller_debug_offset,           --                             .debug_offset
        cam_controller_debug_pixfifodataout   => INT_cam_controller_debug_pixfifodataout,   --                             .debug_pixfifodataout

        --cam_controller_debug_addressupdate    => GPIO_0_LT24_D(0),    --                             .debug_addressupdate
        --cam_controller_debug_linefifoclear    => GPIO_0_LT24_D(1),    --                             .debug_linefifoclear
        --cam_controller_debug_linefiforr       => GPIO_0_LT24_D(2),       --                             .debug_linefiforr
        --cam_controller_debug_linefifowreq     => GPIO_0_LT24_D(3),     --                             .debug_linefifowreq
        --cam_controller_debug_pixfifofull      => GPIO_0_LT24_D(4),      --                             .debug_pixfifofull
        --cam_controller_debug_pixfiforreq      => GPIO_0_LT24_D(5),      --                             .debug_pixfiforreq
        --cam_controller_debug_pixeldatawreq    => GPIO_0_LT24_RD_N,    --                             .debug_pixeldatawreq
        --cam_controller_debug_waitreqmaster    => GPIO_0_LT24_WR_N,    --                             .debug_waitreqmaster
        --cam_controller_debug_writemaster      => GPIO_0_LT24_RS,      --                             .debug_writemaster
        --cam_controller_debug_burstcountmaster => GPIO_0_LT24_D(9 downto 6), --                             .debug_burstcountmaster
        --cam_controller_debug_byteenablemaster => GPIO_0_LT24_D(13 downto 10), --                             .debug_byteenablemaster
        pll_0_outclk0_clk                   => GPIO_1_D5M_XCLKIN                    --                pll_0_outclk0.clk
    );

    ---- CamerInterface debug
    --GPIO_0_LT24_D(0) <= GPIO_1_D5M_PIXCLK;
    --GPIO_0_LT24_D(1) <= INT_cam_controller_debug_linefifowreq;
    --GPIO_0_LT24_D(2) <= INT_cam_controller_debug_linefiforr;
    --GPIO_0_LT24_D(3) <= INT_cam_controller_debug_pixfifowreq;
    --GPIO_0_LT24_D(5 DOWNTO 4) <= INT_cam_controller_debug_pixelstate;
    --GPIO_0_LT24_D(7 DOWNTO 6) <= INT_cam_controller_debug_linestate;
    --GPIO_0_LT24_D(9 DOWNTO 8) <= INT_cam_controller_debug_linefifodata(1 DOWNTO 0);
    --GPIO_0_LT24_D(15 DOWNTO 10) <= INT_cam_controller_debug_pixfifodata(5 DOWNTO 0);
    --GPIO_0_LT24_RD_N <= INT_cam_controller_debug_pixfiforreq;
    --GPIO_0_LT24_WR_N <= INT_cam_controller_debug_linefifoclear;
    --GPIO_0_LT24_RS <= INT_cam_controller_debug_addressupdate;

    DEBUG_addr_msb_is_not_zero <= '0' when INT_cam_controller_debug_addressmaster(31 DOWNTO 15) = std_logic_vector(to_unsigned(0,17)) else '1';
    DEBUG_offset_msb_is_not_zero <= '0' when INT_cam_controller_debug_offset(31 DOWNTO 15) = std_logic_vector(to_unsigned(0,17)) else '1';

     -- AvalonMaster debug
    GPIO_0_LT24_D(0) <= FPGA_CLK1_50;
    GPIO_0_LT24_D(1) <= INT_cam_controller_debug_writemaster;
    GPIO_0_LT24_D(2) <= INT_cam_controller_debug_waitreqmaster;
    GPIO_0_LT24_D(3) <= DEBUG_addr_msb_is_not_zero;
    GPIO_0_LT24_D(15 DOWNTO 4) <= INT_cam_controller_debug_addressmaster(14 DOWNTO 3);
    GPIO_0_LT24_RD_N <= INT_cam_controller_debug_writedatamaster(0);
    GPIO_0_LT24_WR_N <= INT_cam_controller_debug_byteenablemaster(0);
    GPIO_0_LT24_RS <= INT_cam_controller_debug_burstcountmaster(3);

    -- -- AvalonMaster debug data path
    --GPIO_0_LT24_D(0) <= FPGA_CLK1_50;
    --GPIO_0_LT24_D(1) <= INT_cam_controller_debug_pixfiforreq;
    --GPIO_0_LT24_D(2) <= INT_cam_controller_debug_writemaster;
    --GPIO_0_LT24_D(3) <= INT_cam_controller_debug_waitreqmaster;
    --GPIO_0_LT24_D(7 DOWNTO 4) <= INT_cam_controller_debug_pixfifodataout(3 DOWNTO 0);
    --GPIO_0_LT24_D(11 DOWNTO 8) <= INT_cam_controller_debug_writedatamaster(3 DOWNTO 0);
    --GPIO_0_LT24_D(15 DOWNTO 12) <= INT_cam_controller_debug_offset(7 DOWNTO 4);
    --GPIO_0_LT24_RD_N <= INT_cam_controller_debug_pixfifoaclr;
    --GPIO_0_LT24_WR_N <= INT_cam_controller_debug_burstcountmaster(0);
    --GPIO_0_LT24_RS <= INT_cam_controller_debug_burstcountmaster(3);
end;
