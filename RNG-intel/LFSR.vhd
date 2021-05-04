library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
  generic (
    g_Num_Bits : integer := 24
    );
  port (
    i_Clk    : in std_logic;
    i_Enable : in std_logic;
 
    i_Seed_DV   : in std_logic;
    i_Seed_Data : in std_logic_vector(g_Num_Bits-1 downto 0);

    o_LFSR_Data : out std_logic_vector(g_Num_Bits-1 downto 0);
    o_LFSR_Done : out std_logic
    );
end entity LFSR;

architecture RTL of LFSR is

  signal r_LFSR : std_logic_vector(g_Num_Bits downto 1) := (others => '0');
  signal w_XNOR : std_logic;

begin

  p_LFSR : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if i_Enable = '1' then
        if i_Seed_DV = '1' then
          r_LFSR <= i_Seed_Data;
        else
          r_LFSR <= r_LFSR(r_LFSR'left-1 downto 1) & w_XNOR;
        end if;
      end if;
    end if;
  end process p_LFSR;

  g_LFSR_3 : if g_Num_Bits = 3 generate
    w_XNOR <= r_LFSR(3) xnor r_LFSR(2);
  end generate g_LFSR_3;

  g_LFSR_5 : if g_Num_Bits = 5 generate
    w_XNOR <= r_LFSR(5) xnor r_LFSR(3);
  end generate g_LFSR_5;

  g_LFSR_6 : if g_Num_Bits = 6 generate
    w_XNOR <= r_LFSR(6) xnor r_LFSR(5);
  end generate g_LFSR_6;

  g_LFSR_9 : if g_Num_Bits = 9 generate
    w_XNOR <= r_LFSR(9) xnor r_LFSR(5);
  end generate g_LFSR_9;

  g_LFSR_11 : if g_Num_Bits = 11 generate
    w_XNOR <= r_LFSR(11) xnor r_LFSR(9);
  end generate g_LFSR_11;

  g_LFSR_14 : if g_Num_Bits = 14 generate
    w_XNOR <= r_LFSR(14) xnor r_LFSR(5) xnor r_LFSR(3) xnor r_LFSR(1);
  end generate g_LFSR_14;

  g_LFSR_17 : if g_Num_Bits = 17 generate
    w_XNOR <= r_LFSR(17) xnor r_LFSR(14);
  end generate g_LFSR_17;

  g_LFSR_18 : if g_Num_Bits = 18 generate
    w_XNOR <= r_LFSR(18) xnor r_LFSR(11);
  end generate g_LFSR_18;

  g_LFSR_19 : if g_Num_Bits = 19 generate
    w_XNOR <= r_LFSR(19) xnor r_LFSR(6) xnor r_LFSR(2) xnor r_LFSR(1);
  end generate g_LFSR_19;

  g_LFSR_21 : if g_Num_Bits = 21 generate
    w_XNOR <= r_LFSR(21) xnor r_LFSR(19);
  end generate g_LFSR_21;

  g_LFSR_22 : if g_Num_Bits = 22 generate
    w_XNOR <= r_LFSR(22) xnor r_LFSR(21);
  end generate g_LFSR_22;

  g_LFSR_23 : if g_Num_Bits = 23 generate
    w_XNOR <= r_LFSR(23) xnor r_LFSR(18);
  end generate g_LFSR_23;

  g_LFSR_24 : if g_Num_Bits = 24 generate
    w_XNOR <= r_LFSR(24) xnor r_LFSR(23) xnor r_LFSR(22) xnor r_LFSR(17);
  end generate g_LFSR_24;

  o_LFSR_Data <= r_LFSR(r_LFSR'left downto 1);
  o_LFSR_Done <= '1' when r_LFSR(r_LFSR'left downto 1) = i_Seed_Data else '0';

end architecture RTL;
