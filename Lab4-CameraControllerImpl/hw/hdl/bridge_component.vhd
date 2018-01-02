library ieee;
use ieee.std_logic_1164.all;

entity bridge_component is
    port(
    Clk                     : IN std_logic;
    nReset                  : IN std_logic;
    
    avs_address          : IN std_logic_vector(25 DOWNTO 0); -- address direction: Input width: 26 SLAVE_ADDRESS_WIDTH
    avs_burstcount       : IN std_logic_vector(6 DOWNTO 0); -- burstcount direction: Input width: 7 BURSTCOUNT_WIDTH
    avs_byteenable       : IN std_logic_vector(3 DOWNTO 0); -- byteenable direction: Input width: 4 BYTEENABLE_WIDTH
    avs_read             : IN std_logic; -- read direction: Input width: 1 1
    avs_readdata         : OUT std_logic_vector(31 DOWNTO 0); -- readdata direction: Output width: 32 DATA_WIDTH
    avs_readdatavalid    : OUT std_logic; -- readdatavalid direction: Output width: 1 1
    avs_waitrequest      : OUT std_logic; -- waitrequest direction: Output width: 1 1
    avs_write            : IN std_logic; -- write direction: Input width: 1 1
    avs_writedata        : IN std_logic_vector(31 DOWNTO 0); -- writedata direction: Input width: 32 DATA_WIDTH

    avm_address          : OUT std_logic_vector(25 DOWNTO 0);
    avm_burstcount       : OUT std_logic_vector(6 DOWNTO 0);
    avm_byteenable       : OUT std_logic_vector(3 DOWNTO 0);
    avm_read             : OUT std_logic;
    avm_readdata         : IN std_logic_vector(31 DOWNTO 0);
    avm_readdatavalid    : IN std_logic;
    avm_waitrequest      : IN std_logic;
    avm_write            : OUT std_logic;
    avm_writedata        : OUT std_logic_vector(31 DOWNTO 0);

    DEBUG_address          : OUT std_logic_vector(25 DOWNTO 0);
    DEBUG_burstcount       : OUT std_logic_vector(6 DOWNTO 0);
    DEBUG_byteenable       : OUT std_logic_vector(3 DOWNTO 0);
    DEBUG_read             : OUT std_logic;
    DEBUG_readdata         : OUT std_logic_vector(31 DOWNTO 0);
    DEBUG_readdatavalid    : OUT std_logic;
    DEBUG_waitrequest      : OUT std_logic;
    DEBUG_write            : OUT std_logic;
    DEBUG_writedata        : OUT std_logic_vector(31 DOWNTO 0)
    );
end entity;

architecture rtl of bridge_component is
begin
    
    DEBUG_address <= avs_address;
    DEBUG_burstcount <= avs_burstcount;
    DEBUG_byteenable <= avs_byteenable;
    DEBUG_read <= avs_read;
    DEBUG_readdata <= avm_readdata;
    DEBUG_readdatavalid <= avm_readdatavalid;
    DEBUG_waitrequest <= avm_waitrequest;
    DEBUG_write <= avs_write;
    DEBUG_writedata <= avs_writedata;

    avm_address <= avs_address;
    avm_burstcount <= avs_burstcount;
    avm_byteenable <= avs_byteenable;
    avm_read <= avs_read;
    avs_readdata <= avm_readdata;
    avs_readdatavalid <= avm_readdatavalid;
    avs_waitrequest <= avm_waitrequest;
    avm_write <= avs_write;
    avm_writedata <= avs_writedata;

end architecture rtl;
