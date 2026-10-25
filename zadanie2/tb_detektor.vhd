library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Detektor_Mealy_11100 is
-- Testbench nie ma portów
end tb_Detektor_Mealy_11100;

architecture Behavioral of tb_Detektor_Mealy_11100 is

    -- Deklaracja testowanego komponentu (UUT)
    component Detektor_Mealy_11100 is
        Port ( 
            clk    : in  STD_LOGIC;
            en     : in  STD_LOGIC;
            din    : in  STD_LOGIC;
            y_out  : out STD_LOGIC;
            state  : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Sygnały symulacyjne
    signal clk   : STD_LOGIC := '0';
    signal en    : STD_LOGIC := '0';
    signal din   : STD_LOGIC := '0';
    signal y_out : STD_LOGIC;
    signal state : STD_LOGIC_VECTOR(3 downto 0);

    constant clk_period : time := 10 ns; -- Zegar 100 MHz

    -- Procedura symulująca jeden "skok" enkodera obrotowego
    procedure send_bit (
        b : in STD_LOGIC;
        signal en_sig : out STD_LOGIC;
        signal din_sig : out STD_LOGIC
    ) is
    begin
        din_sig <= b;        -- Ustawiamy wartość bitu (0 - lewo, 1 - prawo)
        wait for clk_period / 2;
        en_sig <= '1';       -- Generujemy impuls zezwolenia (en)
        wait for clk_period; -- Trwa jeden takt zegara
        en_sig <= '0';       -- Opuszczamy impuls
        wait for clk_period * 2; -- Przerwa przed kolejnym obrotem enkodera
    end procedure;

begin

    -- Instancjacja badanego modułu
    UUT: Detektor_Mealy_11100 port map (
        clk   => clk,
        en    => en,
        din   => din,
        y_out => y_out,
        state => state
    );

    -- Proces generujący zegar
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proces wprowadzający bodźce testowe
    stim_proc: process
    begin
        -- Czekamy na ustabilizowanie układu
        wait for 50 ns;
        
        -- TEST 1: Idealna, poprawna sekwencja 1 -> 1 -> 1 -> 0 -> 0
        -- Spodziewany wynik: y_out = '1' przy ostatnim bicie
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('0', en, din);
        send_bit('0', en, din); 
        
        wait for 40 ns;

        -- TEST 2: Przerwana sekwencja 1 -> 1 -> 0 -> ...
        -- Układ powinien wrócić do stanu S0 (odrzucić błędny bit)
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('0', en, din); 
        
        wait for 40 ns;

        -- TEST 3: Sekwencja z nadmiarem jedynek (tzw. overlap startowy)
        -- Wpisujemy: 1 -> 1 -> 1 -> 1 -> 0 -> 0
        -- Zgodnie z wytycznymi automatu, układ po wejściu w stan S3 (trzy jedynki) 
        -- powinien w nim zostać przy kolejnych jedynkach, a potem poprawnie wykryć "00".
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('1', en, din); -- Nadmiarowa jedynka
        send_bit('0', en, din);
        send_bit('0', en, din);
        wait for 50 ns;
        -- TEST 4: Obserwacja asynchronicznego wyjścia automatu Mealy'ego w stanie S4
        -- Najpierw wprowadzamy układ w stan S4 (wpisujemy: 1, 1, 1, 0)
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('1', en, din);
        send_bit('0', en, din);

        -- Układ znajduje się teraz w stanie S4. Czekamy chwilę bez wciskania enkodera.
        wait for 30 ns; 
        
        -- Zmieniamy wejście na '1' (Zauważ: en = '0', brak zbocza zegara)
        din <= '1';
        wait for 30 ns; -- OBSERWUJ WYKRES: y_out natychmiast gaśnie ('0')

        -- Zmieniamy wejście z powrotem na '0' 
        din <= '0';
        wait for 30 ns; -- OBSERWUJ WYKRES: y_out natychmiast się zapala ('1')

        -- Jeszcze jedna szybka zmiana dla pewności
        din <= '1';
        wait for 15 ns;
        din <= '0';
        wait for 30 ns;

        -- Dopiero teraz zatwierdzamy nasze '0' "wcisnięciem" przycisku, 
        -- co zresetuje układ do stanu S0
        en <= '1';
        wait for clk_period;
        en <= '0';
        -- Koniec symulacji
        wait;
    end process;

end Behavioral;
