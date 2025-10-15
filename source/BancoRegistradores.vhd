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
        
        entrada   : in  unsigned(15 downto 0); -- conteudo de escrita
        
        saida1    : out unsigned(15 downto 0); -- conteudo do endereço 1
        saida2    : out unsigned(15 downto 0)  -- conteudo do endereço 2
    );
end BancoRegistradores;

architecture Behavioral of BancoRegistradores is
    signal reg_0 : unsigned(15 downto 0) := (others => '0');
    signal reg_1 : unsigned(15 downto 0) := (others => '0');
    signal reg_2 : unsigned(15 downto 0) := (others => '0');
    signal reg_3 : unsigned(15 downto 0) := (others => '0');
    signal reg_4 : unsigned(15 downto 0) := (others => '0');
    signal reg_5 : unsigned(15 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            reg_0 <= "0000000000000000";
            reg_1 <= "0000000000000000";
            reg_2 <= "0000000000000000";
            reg_3 <= "0000000000000000";
            reg_4 <= "0000000000000000";
            reg_5 <= "0000000000000000";
        elsif rising_edge(clk) then
            if wr_en = '1' then
            case addr_wr is
                when "000" =>
                    reg_0 <= entrada;
                when "001" =>
                    reg_1 <= entrada;
                when "010" =>
                    reg_2 <= entrada;
                when "011" =>
                    reg_3 <= entrada;
                when "100" =>
                    reg_4 <= entrada;
                when "101" =>
                    reg_5 <= entrada;
                when others =>
                    null;
            end case;
        end if;
        end if;
    end process;

    with addr_rd1 select
        saida1 <= reg_0 when "000",
        reg_1 when "001",
        reg_2 when "010",
        reg_3 when "011",
        reg_4 when "100",
        reg_5 when "101",
        (others => '0') when others; 
    
    with addr_rd2 select
        saida2 <= reg_0 when "000",
        reg_1 when "001",
        reg_2 when "010",
        reg_3 when "011",
        reg_4 when "100",
        reg_5 when "101",
        (others => '0') when others;

end Behavioral;