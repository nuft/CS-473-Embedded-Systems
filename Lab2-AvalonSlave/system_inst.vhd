	component system is
		port (
			blinky_0_conduit_end_leddata : out std_logic;        -- leddata
			clk_clk                      : in  std_logic := 'X'; -- clk
			reset_reset_n                : in  std_logic := 'X'  -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			blinky_0_conduit_end_leddata => CONNECTED_TO_blinky_0_conduit_end_leddata, -- blinky_0_conduit_end.leddata
			clk_clk                      => CONNECTED_TO_clk_clk,                      --                  clk.clk
			reset_reset_n                => CONNECTED_TO_reset_reset_n                 --                reset.reset_n
		);

