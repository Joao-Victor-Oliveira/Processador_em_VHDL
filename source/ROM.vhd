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
        0  => "00010000011110",
      -- 1: STA R2      ; R2 ("010") = 30
      1  => "01010100000000",
      
      -- A. Carrega R3 (o registrador 3) com o valor 0
      -- 2: LDAI 0
      2  => "00010000000000",
      -- 3: STA R3 ("011")
      3  => "01010110000000",
      
      -- B. Carrega R4 com 0
      -- 4: STA R4 ("100")
      4  => "01011000000000",
      
      -- C. Soma R3 com R4 e guarda em R4
      -- LOOP: (Endereço 5)
      -- 5: LDA R4 ("100")
      5  => "00101000000000",
      -- 6: ADD R3 ("011")
      6  => "00110110000000",
      -- 7: STA R4 ("100")
      7  => "01011000000000",
      
      -- D. Soma 1 em R3
      -- 8: LDA R3 ("011")
      8  => "00100110000000",
      -- 9: ADDI 1 (1 = "0000001")
      9  => "01000000000001",
      -- 10: STA R3 ("011")
      10 => "01010110000000",
      
      -- 11: SUB R2 ("010")
      11 => "01110100000000",

      -- E. Se R3<30 salta para a instrução do passo C (Endereço 5)
      -- 12: BLT -7  ; Salta para 5 se ACC (R3) < R6 (30)
      --    PC_Atual = 12, Alvo = 5
      --    Offset = Alvo - (PC_Atual + 1) = 5 - 12 = -7
      --    R2 = "010", -7 (C2, 7 bits) = "1111000"
      12 => "01110101111000",
      
      -- F. Copia valor de R4 para R5
      -- 13: LDA R4 ("100")
      13 => "00101000000000",
      -- 14: STA R5 ("101")
      14 => "01011010000000",
      
      -- 15: JMP 15 (15 = "0001111")
      15 => "11110000001111",
      others => (others=>'0')
   );
begin
   --Leitura assincrona
   dado <= conteudo_rom(to_integer(endereco));
end architecture;