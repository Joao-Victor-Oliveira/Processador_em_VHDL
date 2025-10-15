library ieee;
use ieee.std_logic_1164.all;

entity tb_uc is
end entity tb_uc;

architecture sim of tb_uc is
    component top_level_LAB_4 is
        port (
            clk : in  std_logic;
            rst : in  std_logic
        );
    end component;

    signal s_clk : std_logic := '0';
    signal s_rst : std_logic;
    constant CLK_PERIOD : time := 10 ns;
begin
    DUT: top_level_LAB_4 port map (clk => s_clk, rst => s_rst);
    s_clk <= not s_clk after CLK_PERIOD / 2;

    process
    begin
        s_rst <= '1';
        wait for 2 * CLK_PERIOD;
        s_rst <= '0';
        wait;
    end process;
end architecture sim;