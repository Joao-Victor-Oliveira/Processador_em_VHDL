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
    constant CLK_PERIOD : time := 20 ns;

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
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
    end process;

    -- 5. Processo de estímulos para testar a funcionalidade
    stimulus_process : process
    begin
        
        rst_tb <= '1';
        addr_tb <= "000";
        constante_tb <= x"0000";
        cte_tb <= '0';
        controle_tb <= "00";
        load_tb <= '1';
        wr_en_tb <= '0';
        addr_wr_tb <= "000";
        wr_entrada_tb <= "0000000000000000";

        wait for CLK_PERIOD*2;
        rst_tb <= '0';

        wr_en_tb <= '1';
        addr_wr_tb <= "000";
        wr_entrada_tb <= x"0010";

        wait for CLK_PERIOD;

        wr_en_tb <= '1';
        addr_wr_tb <= "001";
        wr_entrada_tb <= x"0020";
        controle_tb <= "01";

        wait for CLK_PERIOD;
        
        wr_en_tb <= '0';
        controle_tb <= "00";
        cte_tb   <= '1';
        constante_tb <= x"0007";

        wait for CLK_PERIOD;
        cte_tb   <= '0';
        addr_tb  <= "001";
        
        wait for CLK_PERIOD;
        
        wr_en_tb <= '1';
        addr_wr_tb<= "010";
        wr_entrada_tb <= saida_tb;
        load_tb <= '0';
        wait for CLK_PERIOD;

        load_tb <= '1'; 
        addr_tb <= "010";
        
        wait for CLK_PERIOD;

        addr_wr_tb<= "011";
        wr_entrada_tb <= saida_tb;
        
        wait;

    end process;

end Behavioral;