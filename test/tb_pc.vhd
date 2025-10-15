library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pc is
end entity tb_pc;

architecture sim of tb_pc is

    component pc is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            load    : in  std_logic;
            entrada : in  unsigned(6 downto 0);
            saida   : out unsigned(6 downto 0)
        );
    end component;

    signal s_clk     : std_logic := '0';
    signal s_rst     : std_logic;
    signal s_load    : std_logic;
    signal s_entrada : unsigned(6 downto 0);
    signal s_saida   : unsigned(6 downto 0); 

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT_PC: pc
        port map(
            clk     => s_clk,
            rst     => s_rst,
            load    => s_load,
            entrada => s_entrada,
            saida   => s_saida
        );

    s_clk <= not s_clk after CLK_PERIOD / 2;

    process
    begin
        --Testa o Rst assíncrono
        s_rst     <= '1';
        s_load    <= '1'; 
        s_entrada <= "1010101"; 
        wait for 2 * CLK_PERIOD;
        
        --Testa carregar um valor
        s_rst     <= '0';
        s_load    <= '1'; 
        s_entrada <= "0011001"; -- Valor decimal 25
        wait for 1 * CLK_PERIOD;

        --Testa manter o valor
        s_load    <= '0'; 
        s_entrada <= "1110000"; 
        wait for 3 * CLK_PERIOD; 

        --Testa carregar um novo valor
        s_load    <= '1'; 
        --Novo decimal 112
        wait for 1 * CLK_PERIOD;

    end process;
end architecture sim;