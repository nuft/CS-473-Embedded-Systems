library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity master_tb is
end entity master_tb;
	
architecture bench of master_tb is 
	constant NBITS : natural:= 16;
	constant NBURSTS: natural:= 8;
	constant CLK_PER: time := 20 ns;
	signal main_clk_tb: std_logic:= '0';
	--fifo signals

	signal fifo_rdreq_tb : std_logic;
	signal fifo_empty_tb:  std_logic;
	signal fifo_full_tb:  std_logic;
	--aclr	 => aclr_sig,
	signal fifo_data_out_tb: std_logic_vector(NBITS-1 downto 0);
	--wrreq	 => wrreq_sig,
	signal fifo_almost_full_tb: std_logic;
	--usedw	 => usedw_sig

	--avalon signals

	signal av_waitreq_tb:  std_logic;
	signal av_address_tb:  std_logic_vector(2*NBITS-1 downto 0);
	signal av_burst_count_tb:  std_logic_vector(NBITS-1 downto 0);
	signal av_write_tb: std_logic;
	signal av_byte_enable_tb: std_logic_vector(integer(ceil(log(real(NBITS))))-1 downto 0);
	signal av_write_data_tb: std_logic_vector(2*NBITS-1 downto 0);
	signal av_nreset_tb: std_logic;

	--slave signals

	signal sv_image_address_tb: std_logic_vector(2*NBITS-1 downto 0);
	signal sv_address_update_tb: std_logic;
	signal burst_ready_tb: std_logic;
	signal done : boolean := false;
	type data_array is array(0 to NBITS-1) of std_logic_vector(NBITS-1 downto 0);
	type data_array_int is array (0 to NBITS-1) of integer;
	--constant DATA_1: data_array_int := ((1),(12),(3),(4),(6),(7),(8),(9));
begin
	DUT: entity work.master
		generic map(NBITS => NBITS, NBURSTS => NBURSTS)
		port map (
				main_clk => main_clk_tb,
				fifo_rdreq => fifo_rdreq_tb,
				fifo_empty => fifo_empty_tb,
				fifo_full => fifo_full_tb,
				fifo_data_out => fifo_data_out_tb,
				fifo_almost_full => fifo_almost_full_tb,
				av_waitreq => av_waitreq_tb,
				av_address => av_address_tb,
				av_burst_count => av_burst_count_tb,
				av_write => av_write_tb,
				av_byte_enable => av_byte_enable_tb,
				av_write_data => av_write_data_tb,
				av_nreset => av_nreset_tb,
				sv_image_address => sv_image_address_tb,
				sv_address_update => sv_address_update_tb,
				burst_ready => burst_ready_tb
				);
		main_clk_tb <= not main_clk_tb after CLK_PER/2 when not done;
		av_nreset_tb <= '1', '0' after CLK_PER/4, '1' after CLK_PER*3/4;
		process
			procedure get_full is
			begin
				wait for 2*CLK_PER;
				fifo_full_tb <= '1';
				wait until rising_edge(main_clk_tb);
				fifo_full_tb <= '0';
			end procedure get_full; 
			
			procedure send_data(data_in:data_array_int) is
			begin
				for i in 0 to NBITS-1 loop
					
					fifo_data_out_tb <= std_logic_vector(to_signed(data_in(i), fifo_data_out_tb'length));
					wait until rising_edge(main_clk_tb);
				end loop;
			end procedure send_data;
		
			procedure load_image(addr : integer) is
			begin
				sv_image_address_tb <= std_logic_vector(to_unsigned(addr, sv_image_address_tb'length));
				wait for CLK_PER;
				sv_address_update_tb <= '1';
				wait for CLK_PER;
				sv_address_update_tb <= '0';
				
			end procedure;

		begin
			load_image(20);
			get_full;
			send_data((2,0,4,8,16,32,64,128, 256, -256, -128, -64, -32, -16, 0, -2));
			wait for CLK_PER;
			
			wait for 10*CLK_PER;
			get_full;
			send_data((2,0,4,8,16,32,64,128, 256, -256, -128, -64, -32, -16, 0, -2));
			wait for 10*CLK_PER;
			done <= true;
		end process;	
			
end architecture bench;
		