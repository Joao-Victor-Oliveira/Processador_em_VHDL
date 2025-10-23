library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle is
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
end entity;

architecture behavioral of controle is
    -- Sinal interno para o estado
    signal estado_s  : unsigned (1 downto 0);         
    
    -- Sinais internos para os campos da instrução
    signal opcode    : unsigned(3 downto 0);     
    signal destino   : unsigned(6 downto 0);
    signal reg_addr_i: unsigned(2 downto 0);
    
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
    constant JMP    : unsigned(3 downto 0) := "1111";

    -- NOP  => Não faz nada
    -- LDAI => Load Accumulator with Immediate
	-- LDA  => Load Accumulator
	-- ADD  => Add to Accumulator
	-- ADDI => Add immediate to accumulator
	-- STA  => Store Accumulator's value
	-- JMP  => Jump

begin
    
    -- Decodificador de campos da instrução 
    opcode     <= instr(13 downto 10);  
    destino    <= instr(6 downto 0);    
    reg_addr_i <= instr(9 downto 7); 
    constante  <= STD_LOGIC_VECTOR(instr(9 downto 0));
    

    -- Processo 1: Máquina de Estados (Sequencial - PRECISA de clock)
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
    
    -- Saída do estado (apenas um fio)
    estado <= estado_s;


    -- Controle do Registrador de Instrução 
    wr_en_RI <= '1' when estado_s = FETCH else '0';

    -- Controle do Program Counter
    load_pc <= '1' when estado_s = EXECUTE else '0';
    
    pc_next <= destino when (estado_s = EXECUTE and opcode = JMP) else
               pc_atual + 1;

    -- Controle do Acumulador 
    acc_write_en <= '1' when (estado_s = EXECUTE) and 
                             (opcode = LDAI or opcode = LDA or opcode = ADD or opcode = ADDI) else
                    '0';

    -- Controle do Banco de Registradores 
    reg_write_en <= '1' when (estado_s = EXECUTE and opcode = STA) else
                    '0';

    reg_addr <= reg_addr_i; 

    -- Controle da ULA (ALU)
    with opcode select
        alu_op_sel <= "00" when ADD | ADDI,  -- Operação "ADD"
                      "01" when LDAI | LDA, -- Operação "PASS_B"
                      (others => '0') when others; -- Padrão (não importa)

    with opcode select
        alu_src_b_sel <= '1' when ADDI, -- Fonte B é o Imediato
                         '0' when others;       -- Fonte B é o RegFile (ou não importa)

    with opcode select
            acc_op_sel <= "01" when LDAI,
                          "10" when LDA,
                          "00" when others; 


end behavioral;