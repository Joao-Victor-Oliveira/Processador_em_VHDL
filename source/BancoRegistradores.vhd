library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BancoRegistradores is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        
        wr_en       : in  std_logic; -- habilita a escrita
        
        addr_wr  : in  unsigned(2 downto 0); -- endereço de escrita
        addr_rd1 : in  unsigned(2 downto 0); -- endereço para saida 1
        addr_rd2 : in  unsigned(2 downto 0); -- endereço para saida 2
        
        entrada   : in  std_logic_vector(15 downto 0); -- conteudo de escrita
        
        saida1    : out std_logic_vector(15 downto 0); -- conteudo do endereço 1
        saida2    : out std_logic_vector(15 downto 0)  -- conteudo do endereço 2
    );
end BancoRegistradores;

architecture Behavioral of BancoRegistradores is
    type reg_vetor is array (0 to 5) of std_logic_vector(15 downto 0);
    signal regs : reg_vetor := (others => (others => '0'));
begin

    process(clk, rst)
    begin
        if rst = '1' then
            regs <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if wr_en = '1' then
                if to_integer(addr_wr) < 6 then
                    regs(to_integer(addr_wr)) <= entrada;
                end if;
            end if;
        end if;
    end process;

    saida1 <= regs(to_integer(addr_rd1)) when to_integer(addr_rd1) < 6 else (others => '0');
    saida2 <= regs(to_integer(addr_rd2)) when to_integer(addr_rd2) < 6 else (others => '0');

end Behavioral;