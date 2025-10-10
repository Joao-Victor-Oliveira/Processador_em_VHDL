library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Banco_ULA is
end entity tb_Banco_ULA;

architecture behavior of tb_Banco_ULA is

    -- Constante para o período do clock
    constant CLK_PERIOD : time := 20 ns;

    -- Sinais para Clock e Reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- Sinais de interface com o Banco de Registradores
    signal wr_en      : std_logic := '0';
    signal addr_wr    : unsigned(2 downto 0) := (others => '0');
    signal addr_rd1   : unsigned(2 downto 0) := (others => '0');
    signal addr_rd2   : unsigned(2 downto 0) := (others => '0');
    signal entrada_br : std_logic_vector(15 downto 0) := (others => '0');
    signal saida1_br  : std_logic_vector(15 downto 0);
    signal saida2_br  : std_logic_vector(15 downto 0);

    -- Sinais de interface com a ULA e Acumulador
    signal acumulador_entrada : std_logic_vector(15 downto 0);
    signal acumulador_saida   : std_logic_vector(15 downto 0);
    signal saida_ula          : std_logic_vector(15 downto 0);
    signal load_acc           : std_logic := '0';
    signal controle_ula       : std_logic_vector(1 downto 0) := (others => '0');
    signal cte_ula            : std_logic := '0';
    signal cte_acc            : std_logic := '1'; 
    signal constante_sinal     : std_logic_vector(15 downto 0) := (others => '0');



begin

    -- Instância dos Componentes 
    BR_inst : entity work.BancoRegistradores
        port map(clk=>clk,
        rst=>rst,
        wr_en=>wr_en, 
        addr_wr=>addr_wr, 
        addr_rd1=>addr_rd1, 
        addr_rd2=>addr_rd2, 
        entrada=>entrada_br, 
        saida1=>saida1_br, 
        saida2=>saida2_br);

    ULA_inst : entity work.ULA
        port map(acumulador=>acumulador_saida, 
        registrador=>saida1_br, 
        constante=>constante_sinal, 
        cte=>cte_ula, 
        controle=>controle_ula, 
        saida=>saida_ula);

    Acumulador_inst : entity work.Acumulador
        port map(clk=>clk, 
        rst=>rst, 
        load=>load_acc, 
        entrada=>acumulador_entrada, 
        saida=>acumulador_saida);

    -- Geração de Clock
    clk <= not clk after CLK_PERIOD / 2;

    -- MUX de entrada do Acumulador
    acumulador_entrada <= saida_ula when cte_acc = '1' else saida2_br;

    stim_proc : process
    begin
        -- =============================================================
        -- Fase 1: Reset e Inicialização de Sinais
        -- =============================================================
        report "Iniciando simulacao...";
        rst      <= '1';
        cte_acc  <= '1'; 
        load_acc <= '0';
        wr_en    <= '0';
        cte_ula  <= '0';
        wait for CLK_PERIOD * 1.5;
        rst <= '0';
        wait for CLK_PERIOD;

        -- =============================================================
        -- Fase 2: Carregar valores iniciais nos registradores
        -- =============================================================
        report "Escrevendo valores iniciais em R0 e R1.";
        wr_en      <= '1';
        addr_wr    <= "000"; entrada_br <= x"0014"; wait for CLK_PERIOD;
        addr_wr    <= "001"; entrada_br <= x"0005"; wait for CLK_PERIOD;
        wr_en      <= '0';
        wait for CLK_PERIOD;

        -- =============================================================
        -- Fase 3: Somar R0 + R1 e salvar em R2 (R2 <= 20 + 5 = 25)
        -- =============================================================
        report "Executando: R2 <= R0 + R1";

        -- Ciclo 1: Carrega R0 no Acumulador (usando o novo bypass)
        addr_rd2 <= "000";       
        cte_acc  <= '0';         
        load_acc <= '1';         
        wait for CLK_PERIOD;     

        -- Ciclo 2: Soma o Acumulador com R1 (ACC <= ACC + R1)
        cte_acc      <= '1';     
        addr_rd1     <= "001";   
        controle_ula <= "00";    
        
        wait for CLK_PERIOD*2;     

        -- Ciclo 3: Escreve o resultado do Acumulador em R2
        load_acc   <= '0';       
        wr_en      <= '1';       
        addr_wr    <= "010";     
        entrada_br <= acumulador_saida;
        wait for CLK_PERIOD;
        
        wr_en <= '0';
        wait for CLK_PERIOD * 2;

        -- =============================================================
        -- Fase 4: Subtrair R2 - R1 e salvar em R3 (R3 <= 25 - 5 = 20)
        -- =============================================================
        report "Executando: R3 <= R2 - R1";

        -- Ciclo 1: Carrega R2 no Acumulador
        addr_rd2 <= "010";       
        cte_acc  <= '0';         
        load_acc <= '1';
        wait for CLK_PERIOD;     

        -- Ciclo 2: Subtrai R1 do Acumulador (ACC <= ACC - R1)
        cte_acc      <= '1';      
        addr_rd1     <= "001";    
        controle_ula <= "01";    
        wait for CLK_PERIOD*2;   
        
        -- Ciclo 3: Escreve o resultado em R3
        load_acc   <= '0';
        wr_en      <= '1';
        addr_wr    <= "011";
        entrada_br <= acumulador_saida;
        wait for CLK_PERIOD;
        
        wr_en <= '0';
        wait for CLK_PERIOD * 2;

        -- =============================================================
        -- Fase 5: Testes de SOMA com Constantes
        -- =============================================================

        -- Teste 1: R4 <= R3 + 10 (20 + 10 = 30)
        report "Executando: R4 <= R3 + 10";
        
        -- Ciclo 1: Carrega R3 no Acumulador
        addr_rd2 <= "011"; cte_acc <= '0'; load_acc <= '1'; wait for CLK_PERIOD;
        
        -- Ciclo 2: Soma o Acumulador com a constante 10
        cte_acc <= '1';              
        cte_ula <= '1';              
        controle_ula <= "00";        
        constante_sinal <= x"000A";  
        wait for CLK_PERIOD*2;
        
        -- Ciclo 3: Escreve o resultado em R4
        load_acc <= '0'; cte_ula <= '0'; 
        wr_en <= '1'; addr_wr <= "100"; entrada_br <= acumulador_saida; wait for CLK_PERIOD;
        wr_en <= '0'; wait for CLK_PERIOD * 2;

        -- Teste 2: R5 <= R4 + 100 (30 + 100 = 130)
        report "Executando: R5 <= R4 + 100";
        
        -- Ciclo 1: Carrega R4 no Acumulador
        addr_rd2 <= "100"; cte_acc <= '0'; load_acc <= '1'; wait for CLK_PERIOD;
        
        -- Ciclo 2: Soma com a constante 100
        cte_acc <= '1';
        cte_ula <= '1';
        controle_ula <= "00";
        constante_sinal <= x"0064";
        wait for CLK_PERIOD*2;
        
        -- Ciclo 3: Escreve o resultado em R5
        load_acc <= '0'; cte_ula <= '0';
        wr_en <= '1'; addr_wr <= "101"; entrada_br <= acumulador_saida; wait for CLK_PERIOD;
        wr_en <= '0'; wait for CLK_PERIOD * 2;

        -- Teste 3: R0 <= R5 + (-1) (130 - 1 = 129)
        report "Executando: R0 <= R5 + (-1)";
        
        -- Ciclo 1: Carrega R5 no Acumulador
        addr_rd2 <= "101"; cte_acc <= '0'; load_acc <= '1'; wait for CLK_PERIOD;

        -- Ciclo 2: Soma com a constante -1 (em complemento de 2)
        cte_acc <= '1';
        cte_ula <= '1';
        controle_ula <= "00";
        constante_sinal <= x"FFFF";  -- Define o valor da constante (-1)
        wait for CLK_PERIOD*2;
        
        -- Ciclo 3: Escreve o resultado em R0 (sobrescrevendo o valor antigo)
        load_acc <= '0'; cte_ula <= '0';
        wr_en <= '1'; addr_wr <= "000"; entrada_br <= acumulador_saida; wait for CLK_PERIOD;
        wr_en <= '0'; wait for CLK_PERIOD * 2;


        report "Todos os testes foram concluidos. Parando a simulacao." severity failure;
        wait;
    end process;

end architecture;

