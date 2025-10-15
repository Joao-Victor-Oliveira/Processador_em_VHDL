library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA_ACC is
    Port (
        clk       : in  std_logic;   --usado no acumulador 
        rst       : in  std_logic;   --usado no acumulador
        
        registrador : in  std_logic_vector(15 downto 0); -- conteudo da operacao
        constante : in  STD_LOGIC_VECTOR(15 downto 0); -- cte
        cte       : in std_logic;                      -- seleção da operação com registrador ou cte
        controle  : in STD_LOGIC_VECTOR(1 downto 0);   -- seleção da operação
        load      : in  std_logic;                     -- load acumulador

        saida     : out std_logic_vector(15 downto 0)   -- saida ula
    );
end ULA_ACC;

architecture Behavioral of ULA_ACC is

    component ULA is port(
        acumulador : in STD_LOGIC_VECTOR(15 downto 0); -- acumulador
        
        registrador : in STD_LOGIC_VECTOR(15 downto 0); -- registrador
        constante : in STD_LOGIC_VECTOR(15 downto 0); -- cte
        
        cte: in std_logic;                          -- seleção da operação com registrador ou cte
        controle : in STD_LOGIC_VECTOR(1 downto 0); -- seleção da operação
        
        saida    : out STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;

    component Acumulador is Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(15 downto 0);
        saida    : out std_logic_vector(15 downto 0)
    );
    end component;

    signal entrada_acumulador: std_logic_vector(15 downto 0);
    signal saida_acumulador  : STD_LOGIC_VECTOR(15 downto 0);
    signal saida_ULA         : STD_LOGIC_VECTOR(15 downto 0);
begin
    Acumulador_inst: entity work.Acumulador
     port map(
        clk => clk,
        rst => rst,
        load => load,
        entrada => entrada_acumulador,
        saida => saida_acumulador
    );

    ULA_inst: entity work.ULA
     port map(
        acumulador => saida_acumulador,
        registrador => registrador,
        constante => constante,
        cte => cte,
        controle => controle,
        saida => saida_ULA
    );

    entrada_acumulador <= saida_ULA;
    saida <= saida_ULA;

end Behavioral;