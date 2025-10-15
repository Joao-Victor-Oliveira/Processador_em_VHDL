library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity controle is
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
end entity;

architecture behavioral of controle is
    signal estado_s  : unsigned (1 downto 0);         
    signal opcode    : unsigned(3 downto 0);     
    signal jump_en   : std_logic;
    signal destino   : unsigned(6 downto 0);

    constant FETCH   : unsigned(1 downto 0) := "00";
    constant DECODE  : unsigned(1 downto 0) := "01";
    constant EXECUTE : unsigned(1 downto 0) := "10";
begin
    
    opcode  <= instr(13 downto 10);  --opcode 4 MSB 
    destino <= instr(6 downto 0);    --destino do salto 7 LSB
    
    jump_en <= '1' when opcode = "1111" else '0';

    --maquina de estados, alterna fetch-decode
    process(clk, rst)
    begin
        if rst = '1' then
            estado_s <= FETCH;
        elsif rising_edge(clk) then
            --flip-flop T
            if estado_s = EXECUTE then 
                estado_s <= FETCH;
            else
                estado_s <= estado_s + 1;
            end if;   
        end if;
    end process;

    pc_next <= destino when (estado_s = EXECUTE and jump_en = '1') else pc_atual + 1;

    load_pc <= '1' when estado_s = EXECUTE else '0';

    wr_en_RI <= '1' when estado_s = FETCH else '0';

    estado <= estado_s;

end behavioral;