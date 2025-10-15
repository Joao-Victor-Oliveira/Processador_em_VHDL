library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BR_ULA is
    Port (
        clk       : in  std_logic;  
        rst       : in  std_logic; 
        
        addr      : in  unsigned        (2  downto 0); -- endereço do registrador
        constante : in  STD_LOGIC_VECTOR(15 downto 0); -- cte
        cte       : in std_logic;                      -- selecaoo da operaracao com registrador ou cte
        controle  : in STD_LOGIC_VECTOR(1 downto 0);   -- selecao da operacaoo
        load      : in  std_logic;                     -- load acumulador

        wr_en       : in  std_logic;         -- habilita a escrita
        addr_wr     : in  unsigned(2 downto 0); -- endereço de escrita
        wr_entrada     : in STD_LOGIC_VECTOR(15 downto 0); --conteudo de escrita

        saida     : out std_logic_vector(15 downto 0)   -- saida ula
    );
end BR_ULA;

architecture Behavioral of BR_ULA is

    component ULA_ACC is Port (
        clk       : in  std_logic;   --usado no acumulador 
        rst       : in  std_logic;   --usado no acumulador
        
        registrador : in  std_logic_vector(15 downto 0); -- conteudo da operacao
        constante : in  STD_LOGIC_VECTOR(15 downto 0); -- cte
        cte       : in std_logic;                      -- seleÃ§Ã£o da operacao com registrador ou cte
        controle  : in STD_LOGIC_VECTOR(1 downto 0);   -- seleÃ§Ã£o da operacao
        load      : in  std_logic;                     -- load acumulador

        saida     : out std_logic_vector(15 downto 0)   -- saida ula
    );
    end component;

    component BancoRegistradores is Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        
        wr_en       : in  std_logic; -- habilita a escrita
        
        addr_wr  : in  unsigned(2 downto 0); -- endereço de escrita
        addr_rd1 : in  unsigned(2 downto 0); -- endereço para saida 1
        addr_rd2 : in  unsigned(2 downto 0); -- endereço para saida 2
        
        entrada   : in  std_logic_vector(15 downto 0); -- conteudo de escrita
        
        saida1    : out std_logic_vector(15 downto 0); -- conteudo do endereço 1
        saida2    : out std_logic_vector(15 downto 0)  -- conteudo do endereço 2
    );
    end component;

    signal saida_Bregistradores: STD_LOGIC_VECTOR(15 downto 0);

begin
    ULA_ACC_inst: entity work.ULA_ACC
     port map(
        clk => clk,
        rst => rst,
        registrador => saida_Bregistradores,
        constante => constante,
        cte => cte,
        controle => controle,
        load => load,
        saida => saida
    );

    BancoRegistradores_inst: entity work.BancoRegistradores
     port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        addr_wr => addr_wr,
        addr_rd1 => addr,
        addr_rd2 => "000",
        entrada => wr_entrada,
        saida1 => saida_Bregistradores
    );

end Behavioral;