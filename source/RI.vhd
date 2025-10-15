library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RI is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;                      --Write Enable do Controle 
        entrada : in  unsigned(13 downto 0);          --Entrada vindo da ROM
        saida   : out unsigned(13 downto 0)           --Vai para a UC
    );
end entity RI;

architecture behavioral of RI is
    signal reg_inst_s : unsigned(13 downto 0) := (others => '0');

begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg_inst_s <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                reg_inst_s <= entrada;
            end if;
         end if;
    end process;
   
    saida <= reg_inst_s;

end architecture behavioral;