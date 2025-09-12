LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ULA IS
END ENTITY tb_ULA;

ARCHITECTURE behavior OF tb_ULA IS

    COMPONENT ULA IS
        PORT (
            
            entradaA  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            entradaB  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            controle  : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
            saida     : OUT std_logic_vector(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL entradaA  :   STD_LOGIC_VECTOR(15 DOWNTO 0);
            entradaB  :   STD_LOGIC_VECTOR(15 DOWNTO 0);
            controle  :   STD_LOGIC_VECTOR(1  DOWNTO 0);
            saida     :  STD_LOGIC_VECTOR(15 DOWNTO 0)

    
    -- Constantes para o clock
    CONSTANT CLK_PERIOD : time := 10 ns;

BEGIN
    
    -- 6. Instanciação do DUT (Unit Under Test)
    uut : ULA  
        PORT MAP (
                  => s_clk,
            reset    => s_reset,
            data_in  => s_data_in,
            data_out => s_data_out
        );

    -- 7. Geração do Clock (processo contínuo)
    clk_process : PROCESS
    BEGIN
        s_clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        s_clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS clk_process;

    -- 8. Processo de Estímulo e Verificação
    stimulus_process : PROCESS
    BEGIN
        -- Fase de Reset
        s_reset <= '1';
        s_data_in <= (OTHERS => '0');
        WAIT FOR 2 * CLK_PERIOD; -- Espera alguns ciclos
        s_reset <= '0';
        WAIT FOR CLK_PERIOD;

        -- === INÍCIO DOS CASOS DE TESTE ===

        -- Teste 1: Enviar o valor 42
        REPORT "Iniciando Teste 1: Enviar valor 42";
        s_data_in <= x"2A"; -- 42 em hexadecimal
        WAIT FOR CLK_PERIOD;
        -- (Aqui você pode adicionar verificações)

        -- Teste 2: Enviar o valor 100
        REPORT "Iniciando Teste 2: Enviar valor 100";
        s_data_in <= std_logic_vector(to_unsigned(100, 8));
        WAIT FOR CLK_PERIOD;

        -- Verificação: A saída deve ser o esperado após X ciclos
        WAIT FOR 5 * CLK_PERIOD; -- Ex: esperar a latência do circuito
        ASSERT (s_data_out = "01100100") -- 100 em binário
            REPORT "FALHA: A saída esperada era 100, mas o valor foi " & integer'image(to_integer(unsigned(s_data_out)))
            SEVERITY error;

        -- === FIM DOS CASOS DE TESTE ===

        REPORT "Simulação concluída com sucesso.";
        WAIT; -- Fim da simulação
    END PROCESS stimulus_process;

END ARCHITECTURE;