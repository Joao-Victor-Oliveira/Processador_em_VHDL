library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Este é o testbench principal (top-level)
-- O nome "processador_tb.vhd" é obrigatório pelo PDF do laboratório.
entity processador_tb is
end processador_tb;

architecture behavioral of processador_tb is

    -- Componente a ser testado (UUT - Unit Under Test)
    -- Usamos a versão de depuração para ver os sinais internos.
    component Processador is
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic
        );
    end component;

    -- Constante de tempo para o clock
    constant CLK_PERIOD : time := 10 ns;

    -- Sinais de entrada para o UUT
    signal s_clk : std_logic := '0';
    signal s_rst : std_logic := '0';

    -- Sinais de saída (monitores) do UUT
    -- Estes são os sinais que você deve adicionar no gtkwave,
    -- conforme pedido no PDF.
    signal s_estado    : unsigned(1 downto 0);
    signal s_pc        : std_logic_vector(6 downto 0);
    signal s_instrucao : std_logic_vector(13 downto 0);
    signal s_acc_saida : std_logic_vector(15 downto 0);
    signal s_ula_saida : std_logic_vector(15 downto 0);
   
begin

    -- Instanciação do UUT (Processador)
    UUT : Processador
    port map (
        clk      => s_clk,
        rst      => s_rst
    );

    -- Processo de geração de Clock
    clk_process : process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulo
    stim_proc : process
    begin
        s_rst <= '1';
        wait for CLK_PERIOD * 2;
        
        s_rst <= '0';

        wait;
        
    end process;

end behavioral;
