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
   
   -- Opcodes:
   -- NOP  "0000"
   -- LDAI "0001"
   -- LDA  "0010"
   -- ADD  "0011"
   -- ADDI "0100"
   -- STA  "0101"
   -- BGT  "0110"
   -- SUB  "0111"
   -- BLT  "0111"
   -- SUBI "1000"
   -- SW   "1001"
   -- LW   "1010"
   -- JMP  "1111"
   
   -- Formato Reg/Addr: [OP: 4b]_[REG: 3b]_[ADDR: 7b]
   -- Formato I-Type:   [OP: 4b]_[CONST: 10b]
   
   -- Registradores:
   -- R0: 000
   -- R1: 001
   -- R2: 010
   -- R3: 011
   -- R4: 100
   -- R5: 101

   constant conteudo_rom : mem := (
      -- Programa de Teste (SW e LW - Arquitetura Load/Store)
      
      -- === PARTE 1: Prepara R1 com 3 valores e escreve na RAM ===
      
      -- // R1 = 100
      -- 0: LDAI 100 (Op 0001, Const 0001100100)
      0  => B"0001_0001100100", 
      -- 1: STA R1 (Op 0101, Reg 001, Unused 0000000)
      1  => B"0101_001_0000000", 
      
      -- // RAM[5] = R1 (100)
      -- 2: SW R1, 5 (Op 1001, Reg 001, End RAM 0000101)
      2  => B"1001_001_0000101", 
      
      -- // R1 = 200
      -- 3: LDAI 200 (Op 0001, Const 0011001000)
      3  => B"0001_0011001000", 
      -- 4: STA R1 (Op 0101, Reg 001, Unused 0000000)
      4  => B"0101_001_0000000", 
      
      -- // RAM[6] = R1 (200)
      -- 5: SW R1, 6 (Op 1001, Reg 001, End RAM 0000110)
      5  => B"1001_001_0000110", 

      -- // R1 = 300
      -- 6: LDAI 300 (Op 0001, Const 0100101100)
      6  => B"0001_0100101100", 
      -- 7: STA R1 (Op 0101, Reg 001, Unused 0000000)
      7  => B"0101_001_0000000", 
      
      -- // RAM[7] = R1 (300)
      -- 8: SW R1, 7 (Op 1001, Reg 001, End RAM 0000111)
      8  => B"1001_001_0000111", 

      -- === PARTE 2: Lê os 3 valores da RAM para R2, R3, R4 ===
      
      -- // R2 = RAM[5] (100)
      -- 9: LW R2, 5 (Op 1010, Reg 010, End RAM 0000101)
      9  => B"1010_010_0000101", 
      
      -- // R3 = RAM[6] (200)
      -- 10: LW R3, 6 (Op 1010, Reg 011, End RAM 0000110)
      10 => B"1010_011_0000110", 
      
      -- // R4 = RAM[7] (300)
      -- 11: LW R4, 7 (Op 1010, Reg 100, End RAM 0000111)
      11 => B"1010_100_0000111", 

      -- === PARTE 3: Halt ===
      
      -- 12: JMP 12 (Op 1111, Reg 000, Endereço 0001100)
      12 => B"1111_000_0001100", 
      
      -- Restante da memória é 0
      others => B"0000_000_0000000"
   );
begin
   --Leitura assincrona
   dado <= conteudo_rom(to_integer(endereco));
end architecture;