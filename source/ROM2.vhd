library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port( 
         endereco : in unsigned(15 downto 0); -- Endereço de 7 bits (0 a 127)
         dado     : out unsigned(13 downto 0) -- Dado de saída (Instrução) de 14 bits
   );
end entity;

architecture b_rom of rom is
   type mem is array (0 to 32767) of unsigned(13 downto 0);

   constant conteudo_rom : mem := (
    -- NOP   "0000";
    -- LDAI  "0001";
    -- LDA   "0010";
    -- ADD   "0011";
    -- ADDI  "0100";
    -- STA   "0101";
    -- BGT   "0110";
    -- SUB   "0111";
    -- BLT   "1000";
    -- SUBI  "1001";
    -- SW    "1010";
    -- LW    "1011";
    -- JMP   "1111";

   
   -- Opcode: dado(13 downto 10) | Operando/Endereço: dado(9 downto 0)

   0  => B"0000_0000000000",    --NOP
   1  => B"0001_000_0000101",   --LDAI 5
   2  => B"0100_000_0000101",   --ADDI 5
   3  => B"0101_010_0000000",   --STA R2
   4  => B"0011_010_0000000",   --ADD R2
   5  => B"0111_010_0000000",   --SUB R2
   6  => B"1010_010_010_0000",  --SW R2 R2
   7  => B"0010_000_0000000",   --LDA R0
   8  => B"1011_000_010_0000",  --LW R2
   9  => B"1001_000_0000010",   --SUBI 2
   10 => B"0110_000_0000010",   --BGT 2
   13 => B"1111_000_0001101",   --JMP 13

   others => "00000000000000"

   );
begin
   dado <= conteudo_rom(to_integer(endereco)); -- Atribui o dado (instrução) da memória com base no endereço de entrada
end architecture;