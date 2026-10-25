library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Licznik_Mod9_Neg_Plus3 is
-- Testbench nie posiada portów wejściowych ani wyjściowych
end tb_Licznik_Mod9_Neg_Plus3;

architecture Behavioral of tb_Licznik_Mod9_Neg_Plus3 is

    -- Deklaracja testowanego komponentu (UUT - Unit Under Test)
    component Licznik_Mod9_Neg_Plus3
        Port ( 
            clk : in STD_LOGIC;
            en  : in STD_LOGIC;
            led : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    -- Sygnały symulacyjne
    signal clk : STD_LOGIC := '0';
    signal en  : STD_LOGIC := '0';
    signal led : STD_LOGIC_VECTOR(3 downto 0);

    -- Definicja okresu zegara (np. 50 MHz -> 20 ns)
    constant clk_period : time := 10 ns;

begin

    -- Instancjacja badanego modułu
    UUT: Licznik_Mod9_Neg_Plus3 PORT MAP (
          clk => clk,
          en  => en,
          led => led
        );

    -- Proces generujący sygnał zegarowy
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proces generujący bodźce (symulacja wciskania przycisku)
    stim_proc: process
    begin
        -- Inicjalne opóźnienie (obserwacja stanu początkowego)
        wait for 50 ns;
        
        -- Pętla symulująca 12 kliknięć przycisku (pełny cykl mod 9 + 3 dodatkowe kroki)
        for i in 0 to 44 loop
            -- Symulacja wciśnięcia przycisku (stan wysoki na 1 cykl zegara)
            en <= '1';
            wait for clk_period;
            
            -- Puszczenie przycisku i przerwa przed kolejnym wciśnięciem
            en <= '0';
            wait for clk_period * 3;
        end loop;

        -- Zakończenie symulacji
        wait;
    end process;

end Behavioral;
