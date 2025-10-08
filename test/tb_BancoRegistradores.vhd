library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_BancoRegistradores is
end entity tb_BancoRegistradores;

architecture behavior of tb_BancoRegistradores is
    --ULA e Acumulador
    signal acumulador_entrada : std_logic_vector(15 downto 0);
    signal acumulador_saida   : std_logic_vector(15 downto 0);
    signal registrador        : std_logic_vector(15 downto 0);
    signal constante          : std_logic_vector(15 downto 0);
    signal controle           : std_logic_vector(1 downto 0);
    signal cte                : std_logic;
    signal load_acc           : std_logic;

    --Banco de Registradores
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal wr_en      : std_logic := '0';
    signal addr_wr    : unsigned(2 downto 0) := (others => '0');
    signal addr_rd1   : unsigned(2 downto 0) := (others => '0');
    signal addr_rd2   : unsigned(2 downto 0) := (others => '0');
    signal entrada_br : std_logic_vector(15 downto 0) := (others => '0');
    signal saida1_br  : std_logic_vector(15 downto 0);
    signal saida2_br  : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin
    ULA_inst : entity work.ULA
        port map(
            acumulador  => acumulador_saida,
            registrador => registrador,
            constante   => constante,
            cte         => cte,
            controle    => controle,
            saida       => acumulador_entrada
        );
    Acumulador_inst : entity work.Acumulador
        port map(
            clk     => clk,
            rst     => rst,
            load    => load_acc,
            entrada => acumulador_entrada,
            saida   => acumulador_saida
        );
    BR_inst : entity work.BancoRegistradores
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en,
            addr_wr  => addr_wr,
            addr_rd1 => addr_rd1,
            addr_rd2 => addr_rd2,
            entrada  => entrada_br,
            saida1   => saida1_br,
            saida2   => saida2_br
        );

    clk <= not clk after CLK_PERIOD / 2;

    proc : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for CLK_PERIOD * 1.5;
        rst <= '0';
        wait for CLK_PERIOD;

        --Escreve valores iniciais no banco de registradores
        wr_en <= '1';
        addr_wr <= "000"; entrada_br <= x"000A"; wait for CLK_PERIOD;
        addr_wr <= "001"; entrada_br <= x"0003"; wait for CLK_PERIOD;
        wr_en <= '0';
        wait for CLK_PERIOD;

        --Salva a soma e carrega no acumulador
        addr_rd1 <= "000";         
        registrador <= saida1_br;   
        cte <= '0';
        controle <= "00";           
        load_acc <= '1';            
        wait for CLK_PERIOD;        
        
        --Soma com registradores
        addr_rd1 <= "001";          
        registrador <= saida1_br;   
        load_acc <= '1';
        controle <= "00";           
        wait for CLK_PERIOD;        
        load_acc <= '0';
        
        --Escreve o resultado 
        wr_en <= '1';
        addr_wr <= "010";           
        entrada_br <= acumulador_saida; 
        wait for CLK_PERIOD;        
        wr_en <= '0';
        wait for CLK_PERIOD;

        --Subtrai
        addr_rd1 <= "010";          
        registrador <= saida1_br;
        controle <= "00";
        load_acc <= '1';
        wait for CLK_PERIOD;        
        
        --Subtrai com Acumulador
        addr_rd1 <= "001";          
        registrador <= saida1_br;
        controle <= "01";           
        wait for CLK_PERIOD;        
        load_acc <= '0';
        
        --Escreve o resultado em R3
        wr_en <= '1';
        addr_wr <= "011";           
        entrada_br <= acumulador_saida;
        wait for CLK_PERIOD;        
        wr_en <= '0';
        wait for CLK_PERIOD;

        --Soma com uma constante 
        cte <= '1';                 
        controle <= "00";
        load_acc <= '1';
        wait for CLK_PERIOD;        
        load_acc <= '0';

        --Escreve o resultado no registrador R4
        wr_en <= '1';
        addr_wr <= "100";           
        entrada_br <= acumulador_saida;
        wait for CLK_PERIOD;        
        wr_en <= '0';
        wait for CLK_PERIOD;
        
        --Shifts à direita
        controle <= "10";
        load_acc <= '1';
        wait for CLK_PERIOD;        
        
        --Shift à esquerda
        controle <= "11";
        wait for CLK_PERIOD;        
        load_acc <= '0';
        wait for CLK_PERIOD;

        wait; 
    end process;

end architecture;