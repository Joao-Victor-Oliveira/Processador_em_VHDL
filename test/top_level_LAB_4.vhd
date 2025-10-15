library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_LAB_4 is
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic
    );

end entity top_level_LAB_4;

architecture behavioral of top_level_LAB_4 is
     --Declaração dos Componentes
    component controle is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            instr           : in  unsigned(13 downto 0);
            pc_atual        : in  unsigned(6 downto 0);
            pc_next         : out unsigned(6 downto 0);
            load_pc         : out std_logic
        );
    end component;

    component pc is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            load            : in  std_logic;
            entrada         : in  unsigned(6 downto 0);
            saida           : out unsigned(6 downto 0)
        );
    end component;

    component rom is
        port(
            endereco        : in unsigned(6 downto 0);
            dado            : out unsigned(13 downto 0)
       );
    end component;

    component ULA is
        port (
            acumulador      : in  unsigned(15 downto 0);
            registrador     : in  unsigned(15 downto 0);
            constante       : in  unsigned(15 downto 0);
            cte             : in  std_logic;
            controle        : in  unsigned(1 downto 0);
            saida           : out unsigned(15 downto 0)
        );
    end component;

    component Acumulador is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            load            : in  std_logic;
            entrada         : in  unsigned(15 downto 0); 
            saida           : out unsigned(15 downto 0)  
        );
    end component;

    component BancoRegistradores is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            wr_en           : in  std_logic;
            addr_wr         : in  unsigned(2 downto 0);
            addr_rd1        : in  unsigned(2 downto 0);
            addr_rd2        : in  unsigned(2 downto 0);
            entrada         : in  unsigned(15 downto 0); 
            saida1          : out unsigned(15 downto 0); 
            saida2          : out unsigned(15 downto 0)  
        );
    end component;

    --Sinais de Controle 
    signal pc_saida_s       : unsigned(6 downto 0);
    signal instrucao_s      : unsigned(13 downto 0);
    signal pc_proximo_s     : unsigned(6 downto 0);
    signal pc_load_s        : std_logic;

    -- Sinais de Dados 
    signal ula_saida_s      : unsigned(15 downto 0);
    signal acc_saida_s      : unsigned(15 downto 0);
    signal br_saida1_s      : unsigned(15 downto 0);
    signal br_saida2_s      : unsigned(15 downto 0);
        
     

begin
    -- Instancias
    pc_inst: entity work.pc
     port map(
        clk => clk,
        rst => rst,
        load => pc_load_s,
        entrada => pc_proximo_s,
        saida => pc_saida_s
    );

    rom_inst: entity work.rom
     port map(
        endereco => pc_saida_s,
        dado => instrucao_s
    );

    controle_inst: entity work.controle
     port map(
        clk => clk,
        rst => rst,
        instr => instrucao_s,
        pc_atual => pc_saida_s,
        pc_next => pc_proximo_s,
        load_pc => pc_load_s
    );

    ULA_inst: entity work.ULA
     port map(
        acumulador => acc_saida_s,
        registrador => br_saida1_s,
        constante => (others => '0' ),
        cte => '0',
        controle => "00",
        saida => ula_saida_s
    );

    Acumulador_inst: entity work.Acumulador
     port map(
        clk => clk,
        rst => rst,
        load => '0',
        entrada => ula_saida_s,
        saida => acc_saida_s
    );
    
    BancoRegistradores_inst: entity work.BancoRegistradores
     port map(
        clk => clk,
        rst => rst,
        wr_en => '0',
        addr_wr => instrucao_s(9 downto 7),
        addr_rd1 => instrucao_s(6 downto 4),
        addr_rd2 => (others => '0'),
        entrada => ula_saida_s,
        saida1 => br_saida1_s,
        saida2 => br_saida2_s
    );

end architecture behavioral;