library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_rom is
end entity tb_rom;

architecture sim of tb_rom is

    component rom is
        port(
            endereco : in  unsigned(6 downto 0);
            dado     : out unsigned(13 downto 0)
        );
    end component;

    signal s_endereco : unsigned(6 downto 0) := (others => '0');
    signal s_dado     : unsigned(13 downto 0);

begin

    DUT_ROM: rom
        port map (
            endereco => s_endereco,
            dado     => s_dado
        );

    --Muda o endereço de tempos em tempos.
    process
    begin
        report ">> Iniciando teste da ROM...";

        --Para Endereço 0
        s_endereco <= "0000000"; 
        wait for 10 ns;

        --Para Endereço 1
        s_endereco <= "0000001"; 
        wait for 10 ns;

        --Para Endereço 6 
        s_endereco <= "0000110"; 
        wait for 10 ns;

        --Para Endereço 9
        s_endereco <= "0001001"; 
        wait for 10 ns;

        --Para endereço não especificado (deve retornar zero ) sendo o endereco 50
        s_endereco <= "0110010"; 
        wait for 10 ns;

        --Ultimo endereço possível
        s_endereco <= "1111111"; 
        wait for 10 ns;

    end process;

end architecture sim;