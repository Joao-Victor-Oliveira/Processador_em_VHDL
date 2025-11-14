library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port( 
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(13 downto 0)
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(13 downto 0);
   
   -- Opcodes:
   -- LDAI: 0001
   -- STA:  0101
   -- SW:   1001
   -- LW:   1010
   -- JMP:  1111
   
   -- Formato R-Type: [OP: 4]_[RegA: 3]_[RegB: 3]_[Unused: 4]
   -- Formato I-Type: [OP: 4]_[CONST: 10b]
   
   -- Registradores:
   -- R0: 000, R1: 001, R2: 010, R3: 011
   -- R4: 100, R5: 101 (R6 e R7 não existem)

   constant conteudo_rom : mem := (
      -- Programa de Teste (Arquitetura Híbrida)
      
      -- === PARTE 1: Configurar ponteiros de endereço ===
      
      -- // R1 = 5 (Ponteiro para RAM[5])
      0  => B"0001_0000000101", -- 0: LDAI 5
      1  => B"0101_001_0000000", -- 1: STA R1
      
      -- // R2 = 6 (Ponteiro para RAM[6])
      2  => B"0001_0000000110", -- 2: LDAI 6
      3  => B"0101_010_0000000", -- 3: STA R2

      -- === PARTE 2: Configurar dados e salvar na RAM ===
      
      -- // R4 = 100 (Dado 1)
      4  => B"0001_0001100100", -- 4: LDAI 100
      5  => B"0101_100_0000000", -- 5: STA R4
      
      -- // R5 = 200 (Dado 2)
      6  => B"0001_0011001000", -- 6: LDAI 200
      7  => B"0101_101_0000000", -- 7: STA R5

      -- // Salva os dados na RAM usando ponteiros
      -- 8: SW R4, R1  (Salva R4 (100) no endereço de R1 (5))
      8  => B"1001_100_001_0000",
      
      -- 9: SW R5, R2  (Salva R5 (200) no endereço de R2 (6))
      9  => B"1001_101_010_0000",

      -- === PARTE 3: Ler da RAM para Acumulador e salvar em Regs ===
      
      -- // ACC = RAM[5] (usando ponteiro R1)
      -- 10: LW R0, R1 (Reg R0 é ignorado, endereço vem de R1)
      10 => B"1010_000_001_0000",
      
      -- // R0 = ACC (que contém 100)
      -- 11: STA R0
      11 => B"0101_000_0000000", -- <-- MUDANÇA AQUI (Era R6)
      
      -- // ACC = RAM[6] (usando ponteiro R2)
      -- 12: LW R0, R2 (Reg R0 é ignorado, endereço vem de R2)
      12 => B"1010_000_010_0000",
      
      -- // R3 = ACC (que contém 200)
      -- 13: STA R3
      13 => B"0101_011_0000000", -- <-- MUDANÇA AQUI (Era R7)

      -- === PARTE 4: Halt ===
      -- 14: JMP 14
      14 => B"1111_000_0001110", 
      
      others => B"0000_000_0000000"
   );
begin
   --Leitura assincrona
   dado <= conteudo_rom(to_integer(endereco));
end architecture;