library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controle is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        instr    : in  std_logic_vector(15 downto 0);
        entrada  : in  std_logic_vector(15 downto 0);
        jump_en  : out std_logic
    );
end Controle;

architecture Behavioral of Controle is
   signal opcode: std_logic_vector(3 downto 0);
begin
   opcode <= instr(11 downto 8);
   
   jump_en <=  '1' when opcode="1111" else
               '0';

end Behavioral;