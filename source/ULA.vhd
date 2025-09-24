library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        acumulador : in STD_LOGIC_VECTOR(15 downto 0); -- acumulador
        
        registrador : in STD_LOGIC_VECTOR(15 downto 0); -- registrador
        constante : in STD_LOGIC_VECTOR(15 downto 0); -- cte
        
        cte: in std_logic;                          -- seleção da operação com registrador ou cte
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

    soma <= unsigned(acumulador) + unsigned(registrador) when cte = '0' else unsigned(acumulador) + unsigned(constante);
    subt <= unsigned(acumulador) - unsigned(registrador) when cte = '0' else unsigned(acumulador) - unsigned(constante);

    shiftD(14 downto 0) <= acumulador(15 downto 1);
    shiftD(15) <= acumulador(15);

    shiftE(15 downto 1) <= acumulador(14 downto 0);
    shiftE(0) <= '0';

end architecture behavioral;