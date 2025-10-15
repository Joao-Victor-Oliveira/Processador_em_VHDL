library ieee;
use ieee.std_logic_1164.all;

entity tb_pc_rom is
end entity tb_pc_rom;

architecture sim of tb_pc_rom is

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
    DUT: top_level_LAB_4
        port map (
            clk => s_clk,
            rst => s_rst
        );

    s_clk <= not s_clk after CLK_PERIOD / 2;

    process
    begin
        s_rst <= '1';
        wait for 2 * CLK_PERIOD;
        s_rst <= '0';
        
        --Observando a busca de instruções
        wait for 20 * CLK_PERIOD;
        
        wait;
    end process;

end architecture sim;