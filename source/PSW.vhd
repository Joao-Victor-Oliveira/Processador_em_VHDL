library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PSW is
    Port (

        clk      : in  std_logic;
        rst      : in  std_logic;
        load     : in  std_logic;
        
        z_in    : in std_logic;
        n_in    : in std_logic;
        v_in    : in std_logic;

        z_out    : out std_logic;
        n_out    : out std_logic;
        v_out    : out std_logic

    );
end PSW;

architecture Behavioral of PSW is
    signal z : std_logic;
    signal n : std_logic;
    signal v : std_logic;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            z <= '0';
            n <= '0';
            v <= '0';
        elsif rising_edge(clk) then
            if load = '1' then
                z <= z_in;
                n <= n_in;
                v <= v_in;
            end if;
        end if;
    end process;


    z_out <= z;
    n_out <= n;
    v_out <= v;
end Behavioral;