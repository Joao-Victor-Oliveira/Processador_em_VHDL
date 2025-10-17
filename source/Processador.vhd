library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processador is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        
    );
end Processador;
    

architecture Structural of Processador is
    
    component BR_ULA is
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
    end component;

    component ROM is 
    Port ( 
         endereco : in unsigned(6 downto 0);  --7  bits
         dado     : out unsigned(13 downto 0) --14 bits
    );
    end component;


    component RI is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;                      --Write Enable do Controle 
        entrada : in  unsigned(13 downto 0);          --Entrada vindo da ROM
        saida   : out unsigned(13 downto 0)           --Vai para a UC
    );
    end component;

    component pc is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(6 downto 0); --para 7 bits(128 enderecos)
        saida    : out std_logic_vector(6 downto 0)
    );
    end component;

    component controle is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        instr        : in  unsigned(13 downto 0);  -- 14 bits da ROM
        pc_atual     : in  unsigned(6 downto 0);   
        pc_next      : out unsigned(6 downto 0);   
        load_pc      : out std_logic;               -- habilita o PC
        wr_en_RI     : out std_logic;               -- escrita de registrador de instrucoes
        estado       : out unsigned(1 downto 0)                
    );
    end component;
    

begin

end Structural;