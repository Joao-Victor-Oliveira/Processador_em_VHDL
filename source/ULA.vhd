library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        entradaA : in STD_LOGIC_VECTOR(15 downto 0); -- registrador 1
        
        entradaB : in STD_LOGIC_VECTOR(15 downto 0); -- registrador 2
        entradaC : in STD_LOGIC_VECTOR(15 downto 0); -- constante
        
        constante: in std_logic;                    -- seleção da operação com registrador ou constante
        controle : in STD_LOGIC_VECTOR(1 downto 0); -- seleção da operação
        
        saida    : out STD_LOGIC_VECTOR(15 downto 0)
    );

end entity ULA;

architecture behavioral of ULA is
    signal soma,subt: unsigned(15 downto 0);
    signal shiftD, shiftE : std_logic_vector(15 downto 0);
begin
    with controle select
    saida <= std_logic_vector(soma)   when  "00",
             std_logic_vector(subt)   when  "01",
             shiftD                   when  "10",
             shiftE                   when  "11",
             (others => '0')          when  others;

    soma <= unsigned(entradaA) + unsigned(entradaB) when constante = '0' else unsigned(entradaA) + unsigned(entradaC);
    subt <= unsigned(entradaA) - unsigned(entradaB) when constante = '0' else unsigned(entradaA) - unsigned(entradaC);

    shiftD(14 downto 0) <= entradaA(15 downto 1);
    shiftD(15) <= entradaA(15);

    shiftE(15 downto 1) <= entradaA(14 downto 0);
    shiftE(0) <= '0';

end architecture behavioral;