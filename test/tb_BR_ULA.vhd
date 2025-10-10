-- Declaração das bibliotecas padrão
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A entidade do testbench é geralmente vazia
entity tb_BR_ULA is
end tb_BR_ULA;

architecture Behavioral of tb_BR_ULA is

    -- 1. Declaração do componente que será testado (Device Under Test - DUT)
    component BR_ULA is
        Port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            addr       : in  unsigned(2 downto 0);
            constante  : in  std_logic_vector(15 downto 0);
            cte        : in  std_logic;
            controle   : in  std_logic_vector(1 downto 0);
            load       : in  std_logic;
            wr_en      : in  std_logic;
            addr_wr    : in  unsigned(2 downto 0);
            wr_entrada : in  std_logic_vector(15 downto 0);
            saida      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- 2. Declaração dos sinais para conectar ao DUT
    -- Entradas
    signal clk_tb        : std_logic := '0';
    signal rst_tb        : std_logic;
    signal addr_tb       : unsigned(2 downto 0);
    signal constante_tb  : std_logic_vector(15 downto 0);
    signal cte_tb        : std_logic;
    signal controle_tb   : std_logic_vector(1 downto 0);
    signal load_tb       : std_logic;
    signal wr_en_tb      : std_logic;
    signal addr_wr_tb    : unsigned(2 downto 0);
    signal wr_entrada_tb : std_logic_vector(15 downto 0);

    -- Saída
    signal saida_tb : std_logic_vector(15 downto 0);

    -- Constante para o período do clock
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Instanciação do DUT, conectando os sinais do testbench às portas do componente
    uut : BR_ULA
        port map(
            clk        => clk_tb,
            rst        => rst_tb,
            addr       => addr_tb,
            constante  => constante_tb,
            cte        => cte_tb,
            controle   => controle_tb,
            load       => load_tb,
            wr_en      => wr_en_tb,
            addr_wr    => addr_wr_tb,
            wr_entrada => wr_entrada_tb,
            saida      => saida_tb
        );

    -- 4. Processo para gerar o sinal de clock
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 5. Processo de estímulos para testar a funcionalidade
    stimulus_process : process
    begin
        -- ** FASE 1: RESET **
        -- Inicia com o reset ativado para levar o circuito a um estado conhecido
        rst_tb <= '1';
        wait for 25 ns; -- Mantém o reset por 2 ciclos de clock
        rst_tb <= '0';
        wait for CLK_PERIOD;

        load_tb <= '0';
        
        -- Escreve o valor 10 (0x000A) no registrador de endereço "001"
        wr_en_tb      <= '1';
        addr_wr_tb    <= "001";
        wr_entrada_tb <= x"000A";
        wait for CLK_PERIOD; -- Aguarda um ciclo de clock para a escrita ser efetivada

        -- Escreve o valor 20 (0x0014) no registrador de endereço "010"
        addr_wr_tb    <= "010";
        wr_entrada_tb <= x"0014";
        wait for CLK_PERIOD;

        -- Desativa a escrita nos registradores
        wr_en_tb <= '0';
        wait for CLK_PERIOD;

        -- Carrega o valor do registrador 1 (que é 10) no acumulador
        addr_tb     <= "001"; -- Seleciona o registrador 1 para leitura
        cte_tb      <= '0';     -- Usa o valor do registrador, não a constante
        controle_tb <= "00";   -- Operação de SOMA (para carregar o primeiro valor)
        load_tb     <= '1';     -- Habilita o load no acumulador
        wait for CLK_PERIOD;
        load_tb     <= '0';     -- Desabilita o load
        
        -- Agora, soma o valor do registrador 2 (que é 20) com o acumulador
        addr_tb <= "010"; -- Seleciona o registrador 2
        wait for CLK_PERIOD;
        
        -- Neste ponto, a SAÍDA (saida_tb) deve ser 10 + 20 = 30 (ou 0x001E)

        -- ** FASE 4: OPERAÇÃO DA ULA (CONSTANTE + ACUMULADOR) **
        -- Subtrai a constante 5 (0x0005) do valor atual do acumulador (30)
        cte_tb       <= '1';        -- Usa o valor da constante
        constante_tb <= x"0005";  -- Define a constante como 5
        controle_tb  <= "01";      -- Operação de SUBTRAÇÃO
        load_tb      <= '1';        -- Habilita o load/operação
        wait for CLK_PERIOD;
        load_tb      <= '0';
        
        -- Neste ponto, a SAÍDA (saida_tb) deve ser 30 - 5 = 25 (ou 0x0019)
        wait for CLK_PERIOD;

        load_tb <= '0';
        
        wr_en_tb      <= '1';
        addr_wr_tb    <= "001";
        wr_entrada_tb <= saida_tb;

        -- Fim da simulação
        wait;
    end process;

end Behavioral;