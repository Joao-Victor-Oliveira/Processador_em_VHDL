library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Acumulador is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(15 downto 0);
        saida    : out std_logic_vector(15 downto 0)
    );
end Acumulador;

architecture Behavioral of Acumulador is
    signal acc : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            acc <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                acc <= entrada;
            end if;
        end if;
    end process;

    saida <= acc;

end Behavioral;