-- "I pledge my honor that I have abided by the stevens honor system" - Akash Rana, Cooper Garren, Robert Roettger I
-- Special thanks to Dan Cooke, James Lawnrence, Mourad Deihim, and Chase Capron for their contributions and Michael Fischer at www.emb4fun.de whos VHDL code de0cv-blinky was used as the base for this project.
-- We do not take any credit for the work he has done

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
   port (
      CLOCK_50     : in  std_logic;

      FPGA_RESET_N : in  std_logic;

      -- Probably need to change these to using the HEX[0] syntax
      HEX0         : out std_logic_vector(6 downto 0);
      HEX1         : out std_logic_vector(6 downto 0);
      HEX2         : out std_logic_vector(6 downto 0);
      HEX3         : out std_logic_vector(6 downto 0);
      HEX4         : out std_logic_vector(6 downto 0);
      HEX5         : out std_logic_vector(6 downto 0)
   );
end entity top;

architecture syn of top is

   -- FPGA clock reference is 100MHz
   constant FPGA_SYS_CLK_HZ : integer := 100000000;


   --set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_100MHz]

	constant c_NUM_BITS : integer := 24;
   
   -- may need to look into how the pll component is integrated
   component pll_sys
      port (
         refclk   : in  std_logic := '0';
         rst      : in  std_logic := '0';
         outclk_0 : out std_logic;
         locked   : out std_logic
      );
   end component pll_sys;

   -- equivalent to leddec reference in Lab 2
   component seg7_lut is
      port (
         dig_in  : in  std_logic_vector(3 downto 0);
         seg_out : out std_logic_vector(6 downto 0) --;
         --data   : in std_logic_vector(4 downto 0); -- added these two for future use
         --anode  : out std_logic_vector(7 downto 0)
         
      );
   end component seg7_lut;

   signal sys_clk    : std_logic := '0';
   signal pll_locked : std_logic := '0';
   signal reset      : std_logic := '0';
   signal reset_s1   : std_logic := '1';
   signal reset_s2   : std_logic := '1';
   signal reset_s3   : std_logic := '1';
   signal sys_rst    : std_logic;

      
   signal seg_cnt    : std_logic_vector(23 downto 0) := (others => '0');
   signal seg0       : std_logic_vector(6 downto 0)  := (others => '0');
   signal seg1       : std_logic_vector(6 downto 0)  := (others => '0');
   signal seg2       : std_logic_vector(6 downto 0)  := (others => '0');
   signal seg3       : std_logic_vector(6 downto 0)  := (others => '0');
   signal seg4       : std_logic_vector(6 downto 0)  := (others => '0');
   signal seg5       : std_logic_vector(6 downto 0)  := (others => '0');

	signal r_Clk : std_logic := '0';
	signal w_LFSR_Data : std_logic_vector(c_NUM_BITS-1 downto 0);
	signal w_LFSR_Done : std_logic;

begin

   -- not sure what this section is for, probably has something to do with the pll_sys.vhd file
   inst_pll_sys : pll_sys
      port map (
         refclk   => CLOCK_50,
         rst      => not FPGA_RESET_N,
         outclk_0 => sys_clk,
         locked   => pll_locked
      );

   reset <= '1' when ((FPGA_RESET_N = '0') OR (pll_locked = '0')) else '0';

   -- sets all reset variables to 1 if reset = 1
   -- else, if system clock changes from 0 to 1, then set all reset variables to 0
   process (sys_clk, reset)
   begin
      if (reset = '1') then
         reset_s1 <= '1';
         reset_s2 <= '1';
         reset_s3 <= '1';
      elsif rising_edge(sys_clk) then
         reset_s1 <= '0';
         reset_s2 <= reset_s1;
         reset_s3 <= reset_s2;
      end if;
   end process;

   sys_rst <= reset_s3;


  LFSR_1 : entity work.LFSR
    generic map (
      g_Num_Bits => c_NUM_BITS)
    port map (
      i_Clk       => CLOCK_50,
      i_Enable    => '1',
      i_Seed_DV   => '0',
      i_Seed_Data => (others => '0'),
      o_LFSR_Data => w_LFSR_Data,
      o_LFSR_Done => w_LFSR_Done
      );

   process (sys_clk, sys_rst)
   begin
      if (sys_rst = '1') then
         seg_cnt <= (others => '0');
      elsif rising_edge(sys_clk) then
            seg_cnt <= w_LFSR_Data ;
      end if;
   end process;

   -- this section appears to map the displays to their respective values in seg7_lut
   inst_seg0 : seg7_lut
      port map (
         dig_in  => seg_cnt(3 downto 0),
         seg_out => seg0
      );

   inst_seg1 : seg7_lut
      port map (
         dig_in  => seg_cnt(7 downto 4),
         seg_out => seg1
      );

   inst_seg2 : seg7_lut
      port map (
         dig_in  => seg_cnt(11 downto 8),
         seg_out => seg2
      );

   inst_seg3 : seg7_lut
      port map (
         dig_in  => seg_cnt(15 downto 12),
         seg_out => seg3
      );

   inst_seg4 : seg7_lut
      port map (
         dig_in  => seg_cnt(19 downto 16),
         seg_out => seg4
      );

   inst_seg5 : seg7_lut
      port map (
         dig_in  => seg_cnt(23 downto 20),
         seg_out => seg5
      );

      --removed functions associated with the Intel FPGA LEDs

      -- the HEX values seem to map to the entire number on the Intel FPGA board
      -- similar to how the Nexys A7 refers to them as anodes
   HEX0 <= seg0;
   HEX1 <= seg1;
   HEX2 <= seg2;
   HEX3 <= seg3;
   HEX4 <= seg4;
   HEX5 <= seg5;
   -- sample switch statement that may be able to be used in the future, similar to previous labs
	-- HEX <=   "11111110" WHEN dig = "000" ELSE -- 0
	--          "11111101" WHEN dig = "001" ELSE -- 1
	--          "11111011" WHEN dig = "010" ELSE -- 2
	--          "11110111" WHEN dig = "011" ELSE -- 3
	--          "11101111" WHEN dig = "100" ELSE -- 4
	--          "11011111" WHEN dig = "101" ELSE -- 5 
	--          "10111111" WHEN dig = "110" ELSE -- 6
	--          "01111111" WHEN dig = "111" ELSE -- 7
	--          "11111111";
end architecture syn;
