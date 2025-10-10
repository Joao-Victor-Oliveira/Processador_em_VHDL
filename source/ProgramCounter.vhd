library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        entrada  : in  std_logic_vector(6 downto 0); --para 7 bits(128 enderecos)
        saida    : out std_logic_vector(6 downto 0)
    );
end pc;

architecture Behavioral of pc is
    signal counter : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                counter <= entrada;
            end if;
        end if;
    end process;

    saida <= counter;

end Behavioral;