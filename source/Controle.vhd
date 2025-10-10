library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        instr    : in  unsigned(13 downto 0);  -- 14 bits da ROM
        pc_atual : in  unsigned(6 downto 0);   
        pc_next  : out unsigned(6 downto 0);   
        load_pc  : out std_logic               -- habilita o PC
    );
end entity;

architecture behavioral of controle is
    signal estado  : std_logic := '0';         --fetch=0 e execute=1
    signal opcode  : unsigned(3 downto 0);     
    signal jump_en : std_logic;
    signal destino : unsigned(6 downto 0);
begin
    
    opcode  <= instr(13 downto 10);  --opcode 4 MSB 
    destino <= instr(6 downto 0);    --destino do salto 7 LSB
    
    jump_en <= '1' when opcode = "1111" else '0';

    --maquina de estados, alterna fetch-decode
    process(clk, rst)
    begin
        if rst = '1' then
            estado <= '0';
        elsif rising_edge(clk) then
            --flip-flop T
            estado <= not estado;  
        end if;
    end process;

    pc_next <= destino when (estado = '1' and jump_en = '1') else pc_atual + 1;

    load_pc <= '1' when estado = '1' else '0';

end behavioral;