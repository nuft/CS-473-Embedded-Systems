-- VHDL File for master avalon interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master is
	port(
		
		main_clk: in std_logic;
		av_nreset: in std_logic;
		
		--fifo signals
		fifo_rdreq : out std_logic;
		fifo_rdusedw: in std_logic_vector(4 downto 0);
		fifo_data_out: in std_logic_vector(15 downto 0);
		
		--avalon signals
		av_waitreq: in std_logic;
		av_address: out std_logic_vector(31 downto 0);
		av_burst_count: out std_logic_vector(3 downto 0);
		av_write: out std_logic;
		av_byte_enable: out std_logic_vector(3 downto 0);
		av_write_data: out std_logic_vector(31 downto 0);

		--slave signals
		sv_image_address: in std_logic_vector(31 downto 0);
		burst_ready: out std_logic;
		
		-- camera interface signals
		sv_address_update: in std_logic;
		
		-- debug signals
		DEBUG_offset: out std_logic_vector(31 downto 0)
	);
	end entity;
	
architecture rtl of master is

	-- constants & types declaration
	constant BURST_CNT_MAX: integer:= 8;
	constant STORE_CNT_MAX: integer:= 16;	
	constant FIFO_ALMOST_FULL: integer:=16;
	type state_type is (IDLE, STORE, WRITE);
	type out_reg is array(0 to 7) of std_logic_vector(31 downto 0);
	
	-- register signals
	signal state_reg, state_next: state_type; 						                  -- register for state machine
	signal addr_reg, addr_next: std_logic_vector(31 downto 0);						  -- address registers
	signal offset_reg, offset_next: std_logic_vector(31 downto 0);					  
	signal data_reg, data_next, data2_reg, data2_next: std_logic_vector(15 downto 0); -- data registers
	signal data_out_reg, data_out_next: out_reg;
	signal burst_cnt, burst_reg, burst_next: unsigned(7 downto 0);					  -- counter for the WRITE state
	signal store_cnt, store_reg, store_next: unsigned(15 downto 0);					  -- counter for the STORE state
	
	-- control booleans 
	signal burst_finish, store_finish: boolean:= false;								 
begin

	DEBUG_offset <= offset_reg;
   
	--state register definition
	SREG: process(main_clk, av_nreset)
	begin
		if av_nreset ='0' then
			state_reg <= IDLE;
		elsif rising_edge(main_clk) then
			state_reg <= state_next;
		end if;
	end process SREG;
	
	--next state logic
	NSL: process(state_reg, fifo_rdusedw, burst_finish, store_finish)
	begin
		state_next <= state_reg;
		case state_reg is
		when IDLE => if fifo_rdusedw >= std_logic_vector(to_unsigned(FIFO_ALMOST_FULL, fifo_rdusedw'length)) then
						state_next <= STORE;
					end if;
		when STORE => if store_finish then
						state_next <= WRITE;
					end if;
		when WRITE => if burst_finish then
						
						state_next <= IDLE;
					end if;
		end case; 
	end process NSL;
	
	-- address calculation
	ADDR: process(sv_image_address, sv_address_update, burst_finish, offset_reg, addr_reg)
	begin
		addr_next <= addr_reg;
		offset_next <= offset_reg;
		av_address <= std_logic_vector(unsigned(addr_reg) + unsigned(offset_reg));
		if sv_address_update = '1' then			-- new image address
			addr_next <= sv_image_address;  	
			offset_next <= (others => '0');
		elsif burst_finish then					-- add offset after each burst transfer. offset is 32 BYTES 
			offset_next <= std_logic_vector(unsigned(offset_reg) + to_unsigned(4*BURST_CNT_MAX, offset_next'length));
		end if;
	end process ADDR;
	
	-- control and data registers definition
	DREG: process(main_clk, av_nreset)
	begin
		if av_nreset = '0' then
			addr_reg <= (others =>'0');
			offset_reg <= (others =>'0');
			data_reg <= (others =>'0');
			data2_reg <= (others =>'0');
			burst_reg <= (others => '0');
			store_reg <= (others => '0');
			data_out_reg <= (others => (others => '0'));
		elsif rising_edge(main_clk) then
			addr_reg <= addr_next;
			offset_reg <= offset_next;
			data_reg <= data_next;
			data2_reg <= data2_next;
			burst_reg <= burst_next;
			store_reg <= store_next;
			data_out_reg <= data_out_next;
		end if; 				
	end process DREG;
	
	--output logic
	burst_ready <= '1' when state_reg=IDLE else '0';
	
	-- status signals
	burst_finish <= true when burst_next = BURST_CNT_MAX else false;
	store_finish <= true when store_next = STORE_CNT_MAX-1 else false;
	
	--routing MUX
	RMUX: process(store_cnt, burst_cnt, addr_reg, offset_reg, data_out_reg, state_reg, fifo_data_out, data_reg, data2_reg, burst_reg, store_reg)
	begin
		-- default states for the registers (avoid latches)
		burst_next <= (others => '0');
		store_next <= (others => '1');
		av_burst_count <= (others => '0');
		av_write <= '0';
		av_byte_enable <= (others => '0');
		av_write_data <= (others => '0');
		fifo_rdreq <= '0';
		data_next <= (others => '0');
		data2_next <= (others => '0');
		data_out_next <= data_out_reg;
		case state_reg is
		
			when IDLE => null; 
			
			when STORE => fifo_rdreq <= '1';
						  store_next <= store_cnt;																-- increment store counter
						  if (store_cnt(0)='0' and store_cnt < 16) then
							data_next <= fifo_data_out;
						  else
							data_next <= data_reg;
						  end if;
						  
						  if (store_cnt(0)='1' and store_cnt < 16) then
							data2_next <= fifo_data_out;
						  else 
							data2_next <= data2_reg;
						  end if;
						  if (store_reg(0) = '1' and store_reg < 16) then
							data_out_next(to_integer((store_cnt-1)/2)) <= data2_reg & data_reg;					 -- store FIFO data concatenated in 32-bit output register
						  end if;
						  
			when WRITE => av_burst_count <= std_logic_vector(to_unsigned(BURST_CNT_MAX, av_burst_count'length)); -- set burst count to 8
						  av_write <= '1';																		 
						  av_byte_enable <= (others => '1');													 -- enable all 4 bytes for transfer
					 	  av_write_data <= data_out_reg(to_integer(burst_reg));									 -- provide write_data to Avalon bus
					      burst_next <= burst_cnt;																 -- increment burst counter

			end case;
			end process RMUX;
		
	-- functional units
	DPU_FCT: process(store_reg, burst_reg, av_waitreq)													
	begin
		if (store_reg < 16) then
			store_cnt <= store_reg +1;					-- infers a counter for emptying the FIFO. Only incremented in STORE state
		else
			store_cnt <= (others => '0');				-- reset the counter if 15
		end if;
		if (burst_reg < 8 and av_waitreq = '0') then	
			burst_cnt <= burst_reg +1;					-- infers another counter for counting the bursts. Only incremented in WRITE state
		elsif(burst_reg <8 and av_waitreq = '1') then	-- wait for memory to be ready: dont go to next data word.
			burst_cnt <= burst_reg;						
		else
			burst_cnt <= (others => '0');				-- reset the counter if 7
		end if;
	end process DPU_FCT;
		
			 
	
	end architecture;