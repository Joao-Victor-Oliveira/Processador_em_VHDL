library ieee;
use ieee.std_logic_1164.all;

entity tb_ULA is
end entity tb_ULA;

architecture behavior of tb_ULA is
    signal   entradaA  :   STD_LOGIC_VECTOR(15 DOWNTO 0); 
    signal   entradaB  :   STD_LOGIC_VECTOR(15 DOWNTO 0); 
    signal   controle  :   STD_LOGIC_VECTOR(1  DOWNTO 0);  
    signal   saida     :   STD_LOGIC_VECTOR(15 DOWNTO 0); 

begin
    uut :   entity work.ULA   
        PORT MAP (
           entradaA => entradaA,
           entradaB => entradaB,
           controle => controle,
           saida    => saida 
        );

    --##Para "controle"## 
    controle <= "00" after 00  ns,
                "01" after 70  ns,
                "10" after 150 ns,
                "11" after 190 ns;

    --##Para diferentes casos##
    
    entradaA <= X"0000" after 0   ns,     
                X"1388" after 10  ns,   
                X"2040" after 20  ns,   
                X"71B0" after 30  ns,   
                X"D0C0" after 40  ns,   
                X"7FFF" after 50  ns,   
                X"FFFF" after 60  ns,   
                X"4321" after 70  ns,   
                X"1050" after 80  ns,   
                X"8800" after 90  ns,   
                X"0ABC" after 100 ns,   
                X"1111" after 110 ns,   
                X"8000" after 120 ns,   
                X"0001" after 140 ns,   
                X"3A7C" after 150 ns,   
                X"BACE" after 160 ns,   
                X"FF38" after 170 ns,   
                X"0001" after 180 ns,   
                X"0123" after 190 ns,   
                X"CAFE" after 200 ns,   
                X"BEEF" after 210 ns,   
                x"8000" after 220 ns,   
                x"0001" after 230 ns,   
                x"0000" after 240 ns,   
                x"0000" after 250 ns;   

    entradaB <= X"0000" after 0   ns,   
                X"0C1A" after 10  ns,   
                X"EA6D" after 20  ns,   
                X"20A0" after 30  ns,   
                X"40A0" after 40  ns,   
                X"0001" after 50  ns,   
                X"1111" after 70  ns,   
                X"20A0" after 80  ns,   
                X"3000" after 90  ns,   
                X"0DEF" after 100 ns,   
                X"1111" after 110 ns,   
                X"0001" after 120 ns,   
                X"8000" after 130 ns,   
                X"0002" after 140 ns,   
                X"0000" after 150 ns;   
    
END ARCHITECTURE;