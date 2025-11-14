library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        instr        : in  unsigned(13 downto 0);
        pc_atual     : in  unsigned(6 downto 0);   
        
        -- Sinais do PC, RI e Estado 
        pc_next      : out unsigned(6 downto 0);   
        load_pc      : out std_logic;
        wr_en_RI     : out std_logic;
        estado       : out unsigned(1 downto 0);
        
        -- SAÍDAS DE CONTROLE
        acc_write_en : out std_logic;
        reg_write_en : out std_logic;
        
        reg_addr_rd1 : out unsigned(2 downto 0); -- Reg A (Destino/Dado)
        reg_addr_rd2 : out unsigned(2 downto 0); -- Reg B (Endereço/Fonte)
        
        constante    : out STD_LOGIC_VECTOR(9 downto 0);
        acc_op_sel   : out STD_LOGIC_VECTOR(1 downto 0);
        alu_op_sel   : out unsigned(1 downto 0);
        alu_src_b_sel: out std_logic;

        -- Sinais da RAM
        ram_wr_en    : out std_logic;
        ram_in_sel   : out std_logic;
        -- reg_in_sel FOI REMOVIDO

        flag_n_in    : in std_logic;
        flag_v_in    : in std_logic;
        flag_z_in    : in std_logic; 
        load_psw     : out std_logic
    );
end entity;

architecture behavioral of controle is
    -- Sinais internos
    signal estado_s  : unsigned (1 downto 0);         
    signal opcode    : unsigned(3 downto 0);     
    signal destino   : unsigned(6 downto 0);
    signal destino_rel: unsigned(6 downto 0);
    signal reg_addr_a : unsigned(2 downto 0); -- Reg A (instr 9..7)
    signal reg_addr_b : unsigned(2 downto 0); -- Reg B (instr 6..4)
    
    -- Constantes dos estados
    constant FETCH   : unsigned(1 downto 0) := "00";
    constant DECODE  : unsigned(1 downto 0) := "01";
    constant EXECUTE : unsigned(1 downto 0) := "10";

    -- Constantes dos Opcodes
    constant NOP    : unsigned(3 downto 0) := "0000";
    constant LDAI   : unsigned(3 downto 0) := "0001";
    constant LDA    : unsigned(3 downto 0) := "0010";
    constant ADD    : unsigned(3 downto 0) := "0011";
    constant ADDI   : unsigned(3 downto 0) := "0100";
    constant STA    : unsigned(3 downto 0) := "0101";
    constant BGT    : unsigned(3 downto 0) := "0110";
    constant SUB    : unsigned(3 downto 0) := "0111";
    constant BLT    : unsigned(3 downto 0) := "0111";
    constant SUBI   : unsigned(3 downto 0) := "1000";
    constant SW     : unsigned(3 downto 0) := "1001";
    constant LW     : unsigned(3 downto 0) := "1010";
    constant JMP    : unsigned(3 downto 0) := "1111";

    -- Sinais internos de salto
    signal is_less_than    : std_logic;
    signal is_greater_than : std_logic;
    signal take_branch     : std_logic;
    signal offset_sext     : signed(6 downto 0); 
    signal relative_addr   : unsigned(6 downto 0);

begin
    
    -- Decodificador de campos da instrução 
    opcode     <= instr(13 downto 10);  
    destino    <= instr(6 downto 0);
    destino_rel <= instr(6 downto 0);    
    constante  <= STD_LOGIC_VECTOR(instr(9 downto 0));
    reg_addr_a <= instr(9 downto 7);
    reg_addr_b <= instr(6 downto 4); 

    -- (Processo da Máquina de Estados - sem mudança)
    process(clk, rst)
    begin
        if rst = '1' then
            estado_s <= FETCH;
        elsif rising_edge(clk) then
            if estado_s = EXECUTE then 
                estado_s <= FETCH;
            else
                estado_s <= estado_s + 1;
            end if;   
        end if;
    end process;
    estado <= estado_s;


    -- (Controle do RI e PC - sem mudança)
    wr_en_RI <= '1' when estado_s = FETCH else '0';
    load_pc <= '1' when estado_s = EXECUTE else '0';

    -- ## MUDANÇA AQUI: LW agora escreve no Acumulador ##
    acc_write_en <= '1' when (estado_s = EXECUTE) and 
                             (opcode = LDAI or opcode = LDA or opcode = ADD or 
                              opcode = ADDI or opcode = SUB or opcode = SUBI or
                              opcode = LW) else        
                    '0';
                    
    -- ## MUDANÇA AQUI: Apenas STA escreve no RegFile ##
    reg_write_en <= '1' when (estado_s = EXECUTE and opcode = STA) else
                    '0';

    -- (Endereços de Registrador - sem mudança)
    reg_addr_rd1 <= reg_addr_a; 
    reg_addr_rd2 <= reg_addr_b;

    -- (Controle da ULA - sem mudança)
    with opcode select
        alu_op_sel <= "00" when ADD | ADDI,
                      "01" when SUB | SUBI,
                      "10" when LDAI | LDA | LW | SW,
                      (others => '0') when others;

    with opcode select
        alu_src_b_sel <= '1' when LDAI | ADDI | SUBI, 
                         '0' when others;

    -- ## MUDANÇA AQUI: MUX do Acumulador agora inclui LW ##
    -- "00" = ULA (ADD, ADDI, SUB, SUBI)
    -- "01" = Imediato (LDAI)
    -- "10" = RegFile (LDA)
    -- "11" = RAM (LW)
    with opcode select
            acc_op_sel <= "01" when LDAI,
                          "10" when LDA,
                          "11" when LW,
                          "00" when others;

    -- (Lógica de Salto e PC - sem mudança)
    is_less_than    <= '1' when ((flag_n_in xor flag_v_in) and not flag_z_in) = '1' else '0';
    is_greater_than <= '1' when (flag_z_in = '0') and ((flag_n_in xor flag_v_in) = '0') else '0';
    
    take_branch <= '1' when (estado_s = EXECUTE) and
                            ((opcode = BGT and is_greater_than = '1') or
                             (opcode = BLT and is_less_than = '1'))
                   else '0';
                   
    offset_sext   <= resize(signed(destino_rel), pc_atual'length);
    relative_addr <= unsigned(signed(pc_atual) + 1 + offset_sext);

    pc_next <= relative_addr when (take_branch = '1') else
               destino   when (estado_s = EXECUTE and opcode = JMP) else
               pc_atual + 1;

    -- (Controle do PSW - sem mudança)
    load_psw <= '1' when (opcode = ADD or
                        opcode = ADDI or 
                        opcode = SUB or 
                        opcode = SUBI)
                        and estado_s = EXECUTE  else  '0';

    -- (Controle da RAM - sem mudança)
    ram_wr_en <= '1' when (estado_s = EXECUTE and opcode = SW) else '0';
    ram_in_sel <= '1' when (estado_s = EXECUTE and opcode = SW) else '0';
    
end behavioral;