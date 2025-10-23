library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processador is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic
    );
end Processador;
    

architecture Structural of Processador is
    
    -- ##################################################################
    -- ##               DECLARAÇÃO DOS COMPONENTES                     ##
    -- ##################################################################

    component  ULA is
    port (
        acumulador : in STD_LOGIC_VECTOR(15 downto 0); -- acumulador
        registrador : in STD_LOGIC_VECTOR(15 downto 0); -- registrador
        constante : in STD_LOGIC_VECTOR(15 downto 0); -- cte
        cte: in std_logic;                          -- seleção da operação com registrador ou cte
        controle : in STD_LOGIC_VECTOR(1 downto 0); -- seleção da operação
        saida    : out STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;

    component Acumulador is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(15 downto 0);
        saida    : out std_logic_vector(15 downto 0)
    );
    end component;


    component BancoRegistradores is
    Port (
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

    -- ## Definição do 'controle' CORRIGIDA e HARMONIZADA ##
    component controle is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        instr        : in  unsigned(13 downto 0);  -- 14 bits da ROM
        pc_atual     : in  unsigned(6 downto 0);   
        
        -- Sinais do PC, RI e Estado 
        pc_next      : out unsigned(6 downto 0);   
        load_pc      : out std_logic;               -- habilita o PC
        wr_en_RI     : out std_logic;               -- escrita de registrador de instrucoes
        estado       : out unsigned(1 downto 0);
        
        -- SAÍDAS DE CONTROLE
        acc_write_en : out std_logic;  -- Habilita escrita no Acumulador
        reg_write_en : out std_logic;  -- Habilita escrita no Banco de Regs
        reg_addr     : out unsigned(2 downto 0); -- Endereço do registrador (assumindo 3 bits)
        constante    : out STD_LOGIC_VECTOR(9 downto 0);
        acc_op_sel   : out STD_LOGIC_VECTOR(1 downto 0);
        alu_op_sel   : out unsigned(1 downto 0); -- Ex: "00"=ADD, "01"=PASS_B
        alu_src_b_sel: out std_logic               -- Ex: '0'=RegFile, '1'=Imediato
    );
    end component;
    
    -- ##################################################################
    -- ##                 DECLARAÇÃO DOS "FIOS" (SINAIS)               ##
    -- ##################################################################
    
    -- Sinais do Caminho de Instrução
    signal s_pc_saida      : std_logic_vector(6 downto 0);
    signal s_rom_saida     : unsigned(13 downto 0);
    signal s_ri_saida      : unsigned(13 downto 0);

    -- Sinais do Caminho de Dados
    signal s_acc_saida     : std_logic_vector(15 downto 0);
    signal s_ula_saida     : std_logic_vector(15 downto 0);
    signal s_reg_saida1    : std_logic_vector(15 downto 0);
    signal s_imediato_16b  : std_logic_vector(15 downto 0); -- Extensão do imediato
    
    -- Sinais de Controle (saídas da UC)
    -- (Nomes agora casam com as portas do 'controle')
    signal s_cu_pc_next    : unsigned(6 downto 0);
    signal s_cu_load_pc    : std_logic;
    signal s_cu_wr_en_ri   : std_logic;
    signal s_cu_acc_load   : std_logic;
    signal s_cu_reg_wr_en  : std_logic;
    signal s_cu_reg_addr   : unsigned(2 downto 0);
    signal s_cu_ula_op_sel : unsigned(1 downto 0);
    signal s_cu_ula_cte_sel: std_logic;
    signal s_constante     : STD_LOGIC_VECTOR(9 downto 0);
    signal entrada_acc     : STD_LOGIC_VECTOR(15 downto 0);
    signal s_acc_op_sel    : STD_LOGIC_VECTOR(1 downto 0);
    

begin

    -- ##################################################################
    -- ##                "CIRCUHARIA" (LÓGICA CONCORRENTE)             ##
    -- ##################################################################

    -- Extrai o campo imediato (7 bits) da instrução e estende para 16 bits
    -- (com zeros) para alimentar a ULA.
    
    
    -- ##################################################################
    -- ##                INSTANCIAÇÃO DOS COMPONENTES                  ##
    -- ##################################################################

    -- Unidade de Controle (Cérebro)
    U_Controle : controle
    port map (
        clk          => clk,
        rst          => rst,
        instr        => s_ri_saida,              -- Entrada: Instrução atual
        pc_atual     => unsigned(s_pc_saida),    -- Entrada: PC atual
        
        pc_next      => s_cu_pc_next,            
        load_pc      => s_cu_load_pc,            
        wr_en_RI     => s_cu_wr_en_ri,           
        
        acc_write_en => s_cu_acc_load,           -- Saída: Controle do Acumulador
        reg_write_en => s_cu_reg_wr_en,          -- Saída: Controle do Banco de Regs
        reg_addr     => s_cu_reg_addr,           -- Saída: Endereço do Reg
        constante    => s_constante,
        acc_op_sel => s_acc_op_sel,
        alu_op_sel   => s_cu_ula_op_sel,         -- Saída: Operação da ULA
        alu_src_b_sel => s_cu_ula_cte_sel,        -- Saída: MUX da ULA (Cte ou Reg)
        estado       => open                     -- Saída: (Não conectada, p/ debug)
    );

    -- Program Counter (PC)
    U_PC : pc
    port map (
        clk      => clk,
        rst      => rst,
        load     => s_cu_load_pc,                -- Controle da UC
        entrada  => std_logic_vector(s_cu_pc_next), -- Próximo PC
        saida    => s_pc_saida                     -- Saída para ROM e UC
    );

    -- ROM (Memória de Instrução)
    U_ROM : ROM
    port map (
        endereco => unsigned(s_pc_saida),      -- Endereço vem do PC
        dado     => s_rom_saida               -- Dado vai para o RI
    );
    
    -- Instruction Register (RI)
    U_RI : RI
    port map (
        clk     => clk,
        rst     => rst,
        wr_en   => s_cu_wr_en_ri,           -- Controle da UC (só no FETCH)
        entrada => s_rom_saida,             -- Entrada vem da ROM
        saida   => s_ri_saida               -- Saída vai para a UC
    );

    
    with s_acc_op_sel select
        entrada_acc <= s_ula_saida when "00" ,
                       STD_LOGIC_VECTOR(resize(signed(s_constante),16)) when "01",
                       s_reg_saida1 when "10",
                       "0000000000000000" when others;

    -- Acumulador (ACC)
    U_Acumulador : Acumulador
    port map (
        clk      => clk,
        rst      => rst,
        load     => s_cu_acc_load,           -- Controle da UC
        entrada  => entrada_acc ,             -- Entrada vem da ULA
        saida    => s_acc_saida              -- Saída vai para ULA (A) e Banco (STA)
    );

    -- Banco de Registradores
    U_BancoRegs : BancoRegistradores
    port map (
        clk      => clk,
        rst      => rst,
        wr_en    => s_cu_reg_wr_en,          -- Controle da UC (só no STA)
        addr_wr  => s_cu_reg_addr,           -- Endereço de escrita (do 'controle')
        addr_rd1 => s_cu_reg_addr,           -- Endereço de leitura (do 'controle')
        addr_rd2 => (others => '0'),         -- Não utilizado
        entrada  => s_acc_saida,             -- Dado para escrita (vem do ACC)
        saida1   => s_reg_saida1,            -- Saída 1 vai para a ULA
        saida2   => open                     -- Não utilizada
    );

    -- Unidade Lógica e Aritmética (ULA)
    U_ULA : ULA
    port map (
        acumulador => s_acc_saida,             -- Entrada A
        registrador => s_reg_saida1,            -- Entrada B (opção 0)
        constante  => STD_LOGIC_VECTOR(resize(signed(s_constante),16)),          -- Entrada B (opção 1)
        cte        => s_cu_ula_cte_sel,        -- Seletor da Entrada B
        controle   => std_logic_vector(s_cu_ula_op_sel), -- Seletor da Operação (com cast)
        saida      => s_ula_saida              -- Saída vai para o Acumulador
    );
    
end Structural;
