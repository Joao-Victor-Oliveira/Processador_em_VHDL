library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
   port( 
         endereco : in unsigned(6 downto 0);  --7  bits
         dado     : out unsigned(13 downto 0) --14 bits
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(13 downto 0);
   constant conteudo_rom : mem := (
      -- caso endereco => conteudo
      0  => B"0001_0000000101",--LDAI 5
      1  => B"0101_0110000000",--STA R3
      2  => B"0001_0000001000",--LDAI 8
      3  => B"0101_1000000000",--STA R4
      --C
      4  => B"0010_0110000000",--LDA R3
      5  => B"0011_1000000000",--ADD R4
      6  => B"0101_1010000000",--STA R5
      7  => B"0010_1010000000",--LDA R5
      8  => B"0100_1111111111",--ADDI -1
      9  => B"0101_1010000000",--STA R5 
      10 => B"1111_0000001101",--JMP20
      11 => B"0010_0000000000",--LDA zero
      12 => B"0010_1010000000",--LDA R5
      --20
      13 => B"0010_1010000000",--LDA R5
      14 => B"0101_0110000000",--STA R3
      15 => B"1111_0000000100",--JMPC
      16 => B"0010_0000000000",--LDA zero
      17 => B"0101_0000000000",--STA R3

      others => (others=>'0')
   );
begin
   --Leitura assincrona
   dado <= conteudo_rom(to_integer(endereco));
end architecture;