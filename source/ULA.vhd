library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        entradaA : in STD_LOGIC_VECTOR(15 downto 0);
        entradaB : in STD_LOGIC_VECTOR(15 downto 0);
        controle : in STD_LOGIC_VECTOR(1 downto 0);
        
        saida    : out STD_LOGIC_VECTOR(15 downto 0)
    );

end entity ULA;

architecture behavioral of ULA is
    signal soma,subt: unsigned;
    signal shiftD, shiftE : STD_LOGIC_VECTOR(15 downto 0);
begin

    saida <= STD_LOGIC_VECTOR(soma)   when controle = "00";
    saida <= STD_LOGIC_VECTOR(subt)   when controle = "01";
    saida <= shiftD when controle = "10";
    saida <= shiftE when controle = "11";

    soma <= unsigned(entradaA) + unsigned(entradaB);
    subt <= unsigned(entradaA) - unsigned(entradaB);

    shiftD(14 downto 0) <= entradaA(14 downto 0);
    shiftD(15) <= entradaA(15);

    shiftE(15 downto 1) <= entradaA(15 downto 1);
    shiftE(0) <= '0';

end architecture behavioral;