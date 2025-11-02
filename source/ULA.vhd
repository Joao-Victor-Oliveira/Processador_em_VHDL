library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        acumulador  : in  STD_LOGIC_VECTOR(15 downto 0); -- acumulador
        registrador : in  STD_LOGIC_VECTOR(15 downto 0); -- registrador
        constante   : in  STD_LOGIC_VECTOR(15 downto 0); -- cte
        
        cte         : in  std_logic; -- '0' = registrador, '1' = constante
        controle    : in  STD_LOGIC_VECTOR(1 downto 0); -- seleção da operação
        
        saida       : out STD_LOGIC_VECTOR(15 downto 0); -- resultado principal
        
        flag_n_out  : out std_logic; -- N = Negative
        flag_v_out  : out std_logic; -- V = Overflow
        flag_z_out  : out std_logic  -- Z = Zero
    );

end entity ULA;

architecture behavioral of ULA is

    -- Sinais internos para aritmética COM SINAL
    signal s_acumulador, s_registrador, s_constante : signed(15 downto 0);
    signal s_operando_b : signed(15 downto 0);
    signal s_soma, s_subt : signed(15 downto 0);
    
    -- Sinais internos para shifts (sem sinal)
    signal s_shiftD, s_shiftE : std_logic_vector(15 downto 0);
    
    -- Sinais internos para as flags
    signal n_soma, v_soma, z_soma : std_logic;
    signal n_subt, v_subt, z_subt : std_logic;

begin

    s_acumulador  <= signed(acumulador);
    s_registrador <= signed(registrador);
    s_constante   <= signed(constante);

    s_operando_b <= s_registrador when cte = '0' else s_constante;

    s_soma <= s_acumulador + s_operando_b;
    s_subt <= s_acumulador - s_operando_b;
    
    s_shiftD(14 downto 0) <= acumulador(15 downto 1);
    s_shiftD(15)          <= acumulador(15); 
    s_shiftE(15 downto 1) <= acumulador(14 downto 0);
    s_shiftE(0)           <= '0'; 

    -- MUX da Saída Principal
    with controle select
    saida <= std_logic_vector(s_soma) when "00", -- ADD
             std_logic_vector(s_subt) when "01", -- SUB (usado por BGT/BLT)
             s_shiftD                 when "10", -- SHRA
             s_shiftE                 when "11", -- SHL
             (others => '0')          when others;

    -- CÁLCULO DAS FLAGS

    -- Flags para SOMA (A + B)
    z_soma <= '1' when s_soma = 0 else '0';
    n_soma <= s_soma(15); -- Bit de sinal do resultado
    -- Overflow na SOMA: (A+ e B+) -> Res-  OU  (A- e B-) -> Res+
    v_soma <= '1' when (s_acumulador(15) = s_operando_b(15)) and 
                       (s_acumulador(15) /= s_soma(15)) else '0';

    -- Flags para SUBTRAÇÃO (A - B)
    z_subt <= '1' when s_subt = 0 else '0';
    n_subt <= s_subt(15); -- Bit de sinal do resultado
    -- Overflow na SUBTRAÇÃO: (A+ e B-) -> Res-  OU  (A- e B+) -> Res+
    v_subt <= '1' when (s_acumulador(15) /= s_operando_b(15)) and 
                       (s_acumulador(15) /= s_subt(15)) else '0';
                       
    -- MUX das Saídas de Flags
    -- (Flags são '0' para operações de shift ou desconhecidas)
    with controle select
        flag_n_out <= n_soma when "00",
                      n_subt when "01",
                      '0'    when others;
                      
    with controle select
        flag_v_out <= v_soma when "00",
                      v_subt when "01",
                      '0'    when others;

    with controle select
        flag_z_out <= z_soma when "00",
                      z_subt when "01",
                      '0'    when others;

end architecture behavioral;
