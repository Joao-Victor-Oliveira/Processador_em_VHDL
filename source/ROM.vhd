library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port( 
         endereco : in unsigned(15 downto 0); -- Endereço de 7 bits (0 a 127)
         dado     : out unsigned(13 downto 0) -- Dado de saída (Instrução) de 14 bits
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 32767) of unsigned(13 downto 0);

   constant conteudo_rom : mem := (
      -- Opcode: dado(13 downto 10) | Operando/Endereço: dado(9 downto 0)

      -- Preparando a RAM
      0  =>B"0001_0111111111",      -- LDAI (0001) | Valor 511
      1  =>B"0100_0111111111",      -- ADDI (0100) | Valor 511
      2  =>B"0101_001_0000000",     -- STA  (0101) | R1
      3  =>B"0101_001_0000000",     -- STA  (0101) | R1
      4  => B"0001_0000000000",     -- LDAI (0001) | Valor 0
      5  => B"0101_000_0000000",    -- STA  (0101) | R0
      
      6  => B"0010_000_0000000",    -- LDA  (0010) | R0
      7  => B"0101_000_0000000",    -- STA  (0101) | R0
      8  => B"1010_000_000_0000",   -- SW   (1010) | R0, R0 
      9  => B"0100_0000000001",     -- ADDI (0100) | Valor 1
      10  => B"0101_000_0000000",   -- STA  (0101) | R0
      11  => B"0111_001_0000000",   -- SUB  (0111) | R1
      12  => B"1000_000_1111001",   -- BLT  (1000) | -7
      -- Terminou d epreencher a ram

      13  => B"0001_0000000001",    -- LDAI (0001) | Valor 1
      14  => B"0101_000_0000000",   -- STA  (0101) | R0
      -- Loop externo
      15  => B"0010_000_0000000",   -- LDA  (0010) | R0
      16  => B"0100_0000000001",    -- ADDI (0100) | Valor 1
      17  => B"0101_000_0000000",   -- STA  (0101) | R0
      18  => B"0101_010_0000000",   -- STA  (0101) | R2
      -- Loop interno
      19  => B"0010_010_0000000",   -- LDA  (0010) | R2
      20  => B"0011_000_0000000",   -- ADD  (0011) | R0
      21  => B"0101_010_0000000",   -- STA  (0101) | R2
      22  => B"1010_101_010_0000",  -- SW   (1010) | R5, R2
      23  => B"0111_001_0000000",   -- SUB  (0111) | R1
      24  => B"1000_000_1111010",   -- BLT  (1000) | -6
      
      25 => B"0010_000_0000000",    -- LDA  (0010) | R0
      26 => B"1001_0000011000",     -- SUBI (1001) | Valor 24 
      27 => B"1000_000_1110011",    -- BLT  (1000) | -13

      28 => B"0001_0111111111",     -- LDAI (0001) | Valor 511
      29 => B"0100_0001000010",     -- ADDI (0100) | Valor 66
      30 => B"0101_100_0000000",    -- STA  (0101) | R4
      31 => B"0001_0000000000",     -- LDAI (0001) | Valor 0
      32 => B"1011_100_100_0000",   -- LW   (1011) | R4, R4
      33 => B"0101_011_0000000",    -- STA  (0101) | R3
      --Halt
      34 => B"1111_000_0100010",    -- JMP  (1111) | 34 

      5674 => B"0000_0000000000",     -- NOP
      others => B"1110_0000000000"  -- Exceção
   );
begin
   dado <= conteudo_rom(to_integer(endereco)); -- Atribui o dado (instrução) da memória com base no endereço de entrada
end architecture;