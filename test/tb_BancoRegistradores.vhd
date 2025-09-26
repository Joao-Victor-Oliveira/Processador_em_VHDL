library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_BancoRegistradores is
end entity tb_BancoRegistradores;

architecture behavior of tb_BancoRegistradores is
    
    --Banco Registrador--
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';

    signal wr_en       : std_logic; 
    signal addr_wr     : unsigned(2 downto 0); 
    signal addr_rd1    : unsigned(2 downto 0); 
    signal addr_rd2    : unsigned(2 downto 0); 
        
    signal entrada     : std_logic_vector(15 downto 0);
    signal saida1      : std_logic_vector(15 downto 0); 
    signal saida2      : std_logic_vector(15 downto 0);  


begin
    --------------------------------------------------------------------
    -- Banco Registradores
    --------------------------------------------------------------------
    Banco_reegistrador : entity work.BancoRegistradores 
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en,
            addr_wr  => addr_wr,
            addr_rd1 => addr_rd1,
            addr_rd2 => addr_rd2, 
            entrada  => entrada,
            saida1   => saida1,
            saida2   => saida2
    );

    -- Processo de estímulo (aqui aplicamos os vetores de teste)
    stimulus_process: process
    begin
        report "Iniciando Testbench para o Banco de Registradores...";

        -- ===== ESTADO INICIAL E RESET =====
        rst   <= '1'; -- Ativa o reset
        wr_en <= '0';
        wait for 20 ns;
        rst   <= '0'; -- Desativa o reset
        wait for 10 ns;

        -- ===== TESTE 1: Escrever no registrador 3 =====
        report "Teste 1: Escrevendo o valor AAAA no registrador 3";
        wr_en   <= '1';                         -- Habilita escrita
        addr_wr <= "011";                       -- Endereço 3
        entrada <= x"AAAA";                     -- Valor a ser escrito
        
        -- Aplica um pulso de clock manual para efetivar a escrita
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns; -- Borda de subida do clock
        
        wr_en   <= '0';                         -- Desabilita a escrita para segurança
        wait for 10 ns;

        -- ===== TESTE 2: Ler o registrador 3 (saida1) e 0 (saida2) =====
        report "Teste 2: Lendo o registrador 3 (saida1) e o registrador 0 (saida2)";
        addr_rd1 <= "011"; -- Ler do endereço 3
        addr_rd2 <= "000"; -- Ler do endereço 0
        wait for 10 ns; -- Espera a lógica combinacional de leitura propagar
        
        -- Verificação dos valores
        assert saida1 = x"AAAA" report "FALHA no Teste 2: saida1 deveria ser AAAA" severity error;
        assert saida2 = x"0000" report "FALHA no Teste 2: saida2 deveria ser 0000" severity error;
        
        -- ===== TESTE 3: Escrever no registrador 5 =====
        report "Teste 3: Escrevendo o valor 1234 no registrador 5";
        wr_en   <= '1';
        addr_wr <= "101"; -- Endereço 5
        entrada <= x"1234";
        
        -- Aplica pulso de clock
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        
        wr_en   <= '0';
        wait for 10 ns;

        -- ===== TESTE 4: Ler os dois registradores escritos =====
        report "Teste 4: Lendo registrador 3 (saida1) e 5 (saida2)";
        addr_rd1 <= "011"; -- Endereço 3
        addr_rd2 <= "101"; -- Endereço 5
        wait for 10 ns;
        
        assert saida1 = x"AAAA" report "FALHA no Teste 4: saida1 deveria ser AAAA" severity error;
        assert saida2 = x"1234" report "FALHA no Teste 4: saida2 deveria ser 1234" severity error;
        
        -- ===== TESTE 5: Tentar escrever com wr_en = '0' =====
        report "Teste 5: Tentando escrever FFFF no registrador 1 com wr_en desabilitado";
        wr_en   <= '0'; -- Escrita desabilitada
        addr_wr <= "001";
        entrada <= x"FFFF";
        
        -- Aplica pulso de clock
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        
        -- Verifica se o valor não foi alterado
        addr_rd1 <= "001";
        wait for 10 ns;
        assert saida1 = x"0000" report "FALHA no Teste 5: Escrita ocorreu com wr_en='0'" severity error;

        -- ===== TESTE 6: Ler de um endereço inválido (fora do range 0-5) =====
        report "Teste 6: Lendo do endereço inválido 7";
        addr_rd1 <= "111"; -- Endereço 7
        wait for 10 ns;
        
        assert saida1 = x"0000" report "FALHA no Teste 6: Leitura de endereço inválido não retornou zero" severity error;

        report "Todos os testes passaram com sucesso! Finalizando simulação.";
        wait; -- Fim da simulação
    end process;

end architecture; 