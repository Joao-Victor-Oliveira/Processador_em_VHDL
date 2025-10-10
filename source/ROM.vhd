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
      0  => "00000000000010",
      1  => "00100000000000",
      2  => "00000000000000",
      3  => "00000000000000",
      4  => "00100000000000",
      5  => "00000000000010",
      6  => "00111100000011",
      7  => "00000000000010",
      8  => "00000000000010",
      9  => "00000000000000",
      10 => "00000000000000",
      others => (others=>'0')
   );
begin
   --Leitura assincrona
   dado <= conteudo_rom(to_integer(endereco));
end architecture;