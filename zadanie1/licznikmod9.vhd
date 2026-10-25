library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Licznik_Mod9_Neg_Plus3 is
    Port ( 
        clk : in STD_LOGIC;     -- Zegar sprzętowy (np. 50 MHz z płyty)
        en  : in STD_LOGIC;     -- Sygnał zezwolenia (np. przycisk przepuszczony przez debouncer)
        led : out STD_LOGIC_VECTOR (3 downto 0) -- Wyjście na diody (stan Q)
    );
end Licznik_Mod9_Neg_Plus3;

architecture Behavioral of Licznik_Mod9_Neg_Plus3 is
    -- Rejestr pamiętający stan układu. 
    -- Zgodnie z założeniem inicjalizujemy najwyższym stanem: 8 w kodzie +3 (1011)
    signal Q : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    
    -- Sygnał przechowujący stany następne (wejścia przerzutników D)
    signal D : STD_LOGIC_VECTOR(3 downto 0);
begin

    -- 1. Logika kombinacyjna wyznaczająca stan następny (Twoje równania)
    D(3) <= (not Q(2) and Q(1)) or (not Q(2) and Q(0));
    D(2) <= (Q(2) and Q(0)) or (Q(2) and Q(1)) or (Q(3) and not Q(1) and not Q(0));
    D(1) <= Q(1) xnor Q(0);
    D(0) <= not Q(0) or (not Q(3) and not Q(2));

    -- 2. Proces synchroniczny na przerzutnikach D
    process(clk)
    begin
        if rising_edge(clk) then
            -- Układ zmienia stan tylko, gdy podano impuls (en = '1')
            if en = '1' then 
                Q <= D;
            end if;
        end if;
    end process;

    -- 3. Przypisanie sygnałów do wyjść
    led <= Q;

end Behavioral;
