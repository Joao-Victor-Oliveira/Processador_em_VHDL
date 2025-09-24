library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ULA is
end entity tb_ULA;

architecture behavior of tb_ULA is
    signal acumulador_entrada  : std_logic_vector(15 downto 0);
    signal acumulador_saida    : std_logic_vector(15 downto 0);

    signal registrador : std_logic_vector(15 downto 0); 
    signal constante   : std_logic_vector(15 downto 0);
    signal controle    : std_logic_vector(1 downto 0); 
    signal cte         : std_logic;  
    signal saida       : std_logic_vector(15 downto 0);
    
    signal load        : std_logic;
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
begin
    --------------------------------------------------------------------
    -- Instância da ULA
    --------------------------------------------------------------------
    ULA_inst: entity work.ULA
        port map(
            acumulador  => acumulador_saida,
            registrador => registrador,
            constante   => constante,
            cte         => cte,
            controle    => controle,
            saida       => acumulador_entrada
        );

    --------------------------------------------------------------------
    -- Instância do Acumulador
    --------------------------------------------------------------------
    Acumulador_inst: entity work.Acumulador
        port map(
            clk     => clk,
            rst     => rst,
            load    => load,
            entrada => acumulador_entrada,
            saida   => acumulador_saida
        );

    --------------------------------------------------------------------
    -- Geração de clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

 
    stim_proc : process
    begin
        -- Reset inicial
        rst <= '1';
        load <= '0';
        wait for 25 ns;
        rst <= '0';

        ----------------------------------------------------------------
        -- Teste 1: carregar constante no acumulador
        ----------------------------------------------------------------
        constante <= x"0005";
        cte <= '1';
        controle <= "00"; 
        load <= '1';
        wait for 20 ns;
        load <= '0';
        wait for 40 ns;

        ----------------------------------------------------------------
        -- Teste 2: soma com registrador
        ----------------------------------------------------------------
        registrador <= x"0003";
        cte <= '0';
        controle <= "00";
        load <= '1';
        wait for 20 ns;
        load <= '0';
        wait for 40 ns;

        ----------------------------------------------------------------
        -- Teste 3: subtração
        ----------------------------------------------------------------
        registrador <= x"0002";
        controle <= "01"; 
        load <= '1';
        wait for 20 ns;
        load <= '0';
        wait for 40 ns;

        ----------------------------------------------------------------
        -- Teste 4: bit shifts
        ----------------------------------------------------------------
        registrador <= x"00FF";
        controle <= "10"; 
        load <= '1';
        wait for 20 ns;
        load <= '0';
        wait for 40 ns;

        registrador <= x"0F0F";
        controle <= "11"; 
        load <= '1';
        wait for 20 ns;
        load <= '0';
        wait for 40 ns;

        wait;
    end process;

end architecture;
