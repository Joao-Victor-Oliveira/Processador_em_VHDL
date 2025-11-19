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

    -- (Componentes: ULA, Acumulador, BancoRegistradores, ROM, RI, PC, PSW)
    component  ULA is
    port (
        acumulador  : in  STD_LOGIC_VECTOR(15 downto 0); 
        registrador : in  STD_LOGIC_VECTOR(15 downto 0); 
        constante   : in  STD_LOGIC_VECTOR(15 downto 0); 
        cte         : in  std_logic; 
        controle    : in  STD_LOGIC_VECTOR(1 downto 0); 
        saida       : out STD_LOGIC_VECTOR(15 downto 0); 
        flag_n_out  : out std_logic; 
        flag_v_out  : out std_logic; 
        flag_z_out  : out std_logic
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
        wr_en       : in  std_logic; 
        addr_wr  : in  unsigned(2 downto 0); 
        addr_rd1 : in  unsigned(2 downto 0); 
        addr_rd2 : in  unsigned(2 downto 0); 
        entrada   : in  std_logic_vector(15 downto 0); 
        saida1    : out std_logic_vector(15 downto 0); 
        saida2    : out std_logic_vector(15 downto 0)
    );
    end component;

    component ROM is 
    Port ( 
         endereco : in unsigned(15 downto 0);
         dado     : out unsigned(13 downto 0)
    );
    end component;

    component RI is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;
        entrada : in  unsigned(13 downto 0);
        saida   : out unsigned(13 downto 0)
    );
    end component;

    component pc is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(6 downto 0);
        saida    : out std_logic_vector(6 downto 0)
    );
    end component;

    component  PSW is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        z_in    : in std_logic;
        n_in    : in std_logic;
        v_in    : in std_logic;
        z_out    : out std_logic;
        n_out    : out std_logic;
        v_out    : out std_logic
    );
    end component;

    -- ## MUDANÇA AQUI: Definição do componente RAM atualizada ##
    component ram is
    port( 
         clk      : in std_logic;
         endereco : in STD_LOGIC_VECTOR(15 downto 0); -- Era: unsigned(6 downto 0)
         wr_en    : in std_logic;
         dado_in  : in std_logic_vector(15 downto 0);
         dado_out : out std_logic_vector(15 downto 0) 
    );
    end component;

    -- (Componente 'controle' - sem mudança na definição)
    component controle is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        instr        : in  unsigned(13 downto 0);
        pc_atual     : in  unsigned(6 downto 0);   
        
        pc_next      : out unsigned(6 downto 0);   
        load_pc      : out std_logic;
        wr_en_RI     : out std_logic;
        estado       : out unsigned(1 downto 0);
        
        acc_write_en : out std_logic;
        reg_write_en : out std_logic;
        
        reg_addr_rd1 : out unsigned(2 downto 0); 
        reg_addr_rd2 : out unsigned(2 downto 0); 
        
        constante    : out STD_LOGIC_VECTOR(9 downto 0);
        acc_op_sel   : out STD_LOGIC_VECTOR(1 downto 0);
        alu_op_sel   : out unsigned(1 downto 0);
        alu_src_b_sel: out std_logic;

        ram_wr_en    : out std_logic;
        ram_in_sel   : out std_logic;

        flag_n_in    : in std_logic;
        flag_v_in    : in std_logic;
        flag_z_in    : in std_logic; 
        load_psw     : out std_logic
    );
    end component;
    
    
    -- (Todos os Sinais - sem mudança)
    signal s_pc_saida      : std_logic_vector(6 downto 0);
    signal s_rom_saida     : unsigned(13 downto 0);
    signal s_ri_saida      : unsigned(13 downto 0);
    signal s_acc_saida     : std_logic_vector(15 downto 0);
    signal s_ula_saida     : std_logic_vector(15 downto 0);
    signal s_reg_saida1    : std_logic_vector(15 downto 0);
    signal s_reg_saida2    : std_logic_vector(15 downto 0);
    signal s_imediato_16b  : std_logic_vector(15 downto 0);
    signal entrada_acc     : std_logic_vector(15 downto 0);
    signal s_ram_data_out  : std_logic_vector(15 downto 0);
    signal s_ram_data_in   : std_logic_vector(15 downto 0);
    signal s_cu_pc_next    : unsigned(6 downto 0);
    signal s_cu_load_pc    : std_logic;
    signal s_cu_wr_en_ri   : std_logic;
    signal s_cu_acc_load   : std_logic;
    signal s_cu_reg_wr_en  : std_logic;
    signal s_cu_reg_addr_rd1 : unsigned(2 downto 0); 
    signal s_cu_reg_addr_rd2 : unsigned(2 downto 0); 
    signal s_cu_ula_op_sel : unsigned(1 downto 0);
    signal s_cu_ula_cte_sel: std_logic;
    signal s_constante     : std_logic_vector(9 downto 0);
    signal s_acc_op_sel    : std_logic_vector(1 downto 0);
    signal s_load_psw      : std_logic;
    signal s_cu_ram_wr_en  : std_logic;
    signal s_cu_ram_in_sel : std_logic;
    signal s_flag_n, s_flag_v, s_flag_z : std_logic;        
    signal c_flag_n, c_flag_v, c_flag_z : std_logic;       

begin

    -- (Instanciações e lógica - sem mudança até a RAM)
    s_imediato_16b <= std_logic_vector(resize(signed(s_constante), 16));

    U_Controle : controle
    port map (
        clk          => clk, rst => rst, instr => s_ri_saida,
        pc_atual     => unsigned(s_pc_saida),
        pc_next      => s_cu_pc_next,            
        load_pc      => s_cu_load_pc,            
        wr_en_RI     => s_cu_wr_en_ri,           
        acc_write_en => s_cu_acc_load,           
        reg_write_en => s_cu_reg_wr_en,
        reg_addr_rd1 => s_cu_reg_addr_rd1, 
        reg_addr_rd2 => s_cu_reg_addr_rd2, 
        constante    => s_constante,
        acc_op_sel   => s_acc_op_sel,
        alu_op_sel   => s_cu_ula_op_sel,         
        alu_src_b_sel=> s_cu_ula_cte_sel,        
        ram_wr_en    => s_cu_ram_wr_en,
        ram_in_sel   => s_cu_ram_in_sel,
        estado       => open,
        flag_n_in    => c_flag_n, flag_v_in => c_flag_v,
        flag_z_in    => c_flag_z, load_psw  => s_load_psw
    );

    U_PC : pc
    port map (
        clk      => clk, rst => rst, load => s_cu_load_pc,
        entrada  => std_logic_vector(s_cu_pc_next), saida => s_pc_saida
    );
    U_ROM : ROM
    port map (
        endereco(15 downto 7)=> "000000000",endereco(6 downto 0) => unsigned(s_pc_saida), dado => s_rom_saida
    );
    U_RI : RI
    port map (
        clk     => clk, rst => rst, wr_en => s_cu_wr_en_ri,
        entrada => s_rom_saida, saida   => s_ri_saida
    );

    with s_acc_op_sel select
        entrada_acc <= s_ula_saida     when "00",
                       s_imediato_16b  when "01",
                       s_reg_saida1    when "10",
                       s_ram_data_out  when "11",
                       (others => '0') when others;

    U_Acumulador : Acumulador
    port map (
        clk      => clk, rst => rst, load => s_cu_acc_load,
        entrada  => entrada_acc, saida    => s_acc_saida
    );
    
    U_BancoRegs : BancoRegistradores
    port map (
        clk      => clk,
        rst      => rst,
        wr_en    => s_cu_reg_wr_en,
        addr_wr  => s_cu_reg_addr_rd1, 
        addr_rd1 => s_cu_reg_addr_rd1, 
        addr_rd2 => s_cu_reg_addr_rd2, 
        entrada  => s_acc_saida,       
        saida1   => s_reg_saida1,    
        saida2   => s_reg_saida2     
    );

    U_ULA : ULA
    port map (
        acumulador  => s_acc_saida,
        registrador => s_reg_saida1, 
        constante   => s_imediato_16b,
        cte         => s_cu_ula_cte_sel,
        controle    => std_logic_vector(s_cu_ula_op_sel),
        saida       => s_ula_saida,
        flag_n_out  => s_flag_n,
        flag_v_out  => s_flag_v,
        flag_z_out  => s_flag_z 
    );
    U_PSW: PSW
     port map(
        clk    => clk, rst => rst, load => s_load_psw,
        z_in   => s_flag_z, n_in => s_flag_n, v_in => s_flag_v,
        z_out  => c_flag_z, n_out => c_flag_n, v_out => c_flag_v
    );

    s_ram_data_in <= s_reg_saida1 when s_cu_ram_in_sel = '1' else
                     s_acc_saida;

    -- ## MUDANÇA AQUI: Instanciação da RAM atualizada ##
    U_RAM : ram
    port map (
        clk       => clk,
        -- Removida a truncagem (6 downto 0) e a conversão para unsigned
        endereco  => s_reg_saida2,         -- Agora usa o endereço completo de 16 bits
        wr_en     => s_cu_ram_wr_en,
        dado_in   => s_ram_data_in,
        dado_out  => s_ram_data_out
    );
    
end Structural;