	component VGA_pll is
		port (
			clk_clk       : in  std_logic := 'X'; -- clk
			clk_120m_clk  : out std_logic;        -- clk
			clk_100m_clk  : out std_logic;        -- clk
			clk_75m_clk   : out std_logic;        -- clk
			clk_800k_clk  : out std_logic;        -- clk
			reset_reset_n : in  std_logic := 'X'  -- reset_n
		);
	end component VGA_pll;

	u0 : component VGA_pll
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --      clk.clk
			clk_120m_clk  => CONNECTED_TO_clk_120m_clk,  -- clk_120m.clk
			clk_100m_clk  => CONNECTED_TO_clk_100m_clk,  -- clk_100m.clk
			clk_75m_clk   => CONNECTED_TO_clk_75m_clk,   --  clk_75m.clk
			clk_800k_clk  => CONNECTED_TO_clk_800k_clk,  -- clk_800k.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n  --    reset.reset_n
		);

