-- megafunction wizard: %PLL Intel FPGA IP v18.1%
-- GENERATION: XML
-- pll_sys.vhd

-- Generated using ACDS version 18.1 625

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pll_sys is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		locked   : out std_logic         --  locked.export
	);
end entity pll_sys;

architecture rtl of pll_sys is
	component pll_sys_0002 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component pll_sys_0002;

begin

	pll_sys_inst : component pll_sys_0002
		port map (
			refclk   => refclk,   --  refclk.clk
			rst      => rst,      --   reset.reset
			outclk_0 => outclk_0, -- outclk0.clk
			locked   => locked    --  locked.export
		);

end architecture rtl; -- of pll_sys
