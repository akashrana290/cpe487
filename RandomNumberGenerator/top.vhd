-- "I pledge my honor that I have abided by the stevens honor system" -Dan Cooke
-- Special thanks to Michael Fischer at www.emb4fun.de whos VHDL code de0cv-blinky was used as the base for this project.
-- We do not take any credit for the work he has done

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
   port ( 
      CLOCK_50     : in  std_logic;
      
      FPGA_RESET_N : in  std_logic;
      
      LEDR         : out std_logic_vector(9 downto 0);
      
      HEX0         : out std_logic_vector(6 downto 0);
      HEX1         : out std_logic_vector(6 downto 0);
      HEX2         : out std_logic_vector(6 downto 0);
      HEX3         : out std_logic_vector(6 downto 0);
      HEX4         : out std_logic_vector(6 downto 0);
      HEX5         : out std_logic_vector(6 downto 0)
   );
end entity top;

architecture syn of top is

   constant FPGA_SYS_CLK_HZ : integer := 100000000;
   constant LED_CLK_HZ      : integer := 1;
   
   constant LED_CNT_RANGE   : integer := (FPGA_SYS_CLK_HZ / LED_CLK_HZ);
   constant LED_CNT_MAX     : integer := LED_CNT_RANGE - 1;

	constant c_NUM_BITS : integer := 24;
   
   
   component seg7_lut is
      port (
         dig_in  : in  std_logic_vector(3 downto 0);
         seg_out : out std_logic_vector(6 downto 0)
      );
   end component seg7_lut;
	
   signal sys_clk    : std_logic := '0';
   signal reset      : std_logic := '0';
   signal reset_s1   : std_logic := '1';
   signal reset_s2   : std_logic := '1';
   signal reset_s3   : std_logic := '1';
   signal sys_rst    : std_logic;

   signal led_cnt    : integer range 0 to LED_CNT_RANGE;
   signal led_red    : std_logic_vector(9 downto 0)  := "0000000001";
   
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
         if (led_cnt = 0) then
            seg_cnt <= w_LFSR_Data ;
         end if;
      end if;
   end process;
   
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
		
   process (sys_clk, sys_rst)
   begin
      if (sys_rst = '1') then
         led_cnt <= 0; 
      elsif rising_edge(sys_clk) then
         if (led_cnt > 0) then 
            led_cnt <= led_cnt - 1;
         else
            led_cnt <= LED_CNT_MAX;
         end if;      
      end if;
   end process;   
	  
   process (sys_clk, sys_rst)
   begin
      if (sys_rst = '1') then
         led_red <= "0000000001";
      elsif rising_edge(sys_clk) then
         if (led_cnt = 0) then
            led_red <= led_red(8 downto 0) & led_red(9);
         end if;   
      end if;
   end process;   
	
   LEDR <= led_red;
   
   HEX0 <= seg0;
   HEX1 <= seg1;
   HEX2 <= seg2;
   HEX3 <= seg3;
   HEX4 <= seg4;
   HEX5 <= seg5;
         
end architecture syn;