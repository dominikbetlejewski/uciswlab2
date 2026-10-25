library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_Level_Zad1 is
    Port ( 
        clk_100MHz : in STD_LOGIC;     -- Zegar główny z płyty
        btn_manual : in STD_LOGIC;     -- Przycisk do ręcznego zliczania
        sw_auto    : in STD_LOGIC;     -- Przełącznik trybu (0 = ręcznie, 1 = automat)
        led        : out STD_LOGIC_VECTOR (3 downto 0) -- 4 diody na płycie
    );
end Top_Level_Zad1;

architecture Behavioral of Top_Level_Zad1 is

    -- 1. Deklaracja komponentu: Dzielnik Zegara
    component ClockDivider is
        Generic( IN_FREQ_HZ : POSITIVE := 100E6; OUT_FREQ_HZ : POSITIVE := 1 ); 
        Port ( clk_In  : in  std_logic;
               clk_Out : out std_logic );
    end component;

    -- 2. Deklaracja komponentu: Twój Licznik Mod 9
    component Licznik_Mod9_Neg_Plus3 is
        Port ( clk : in STD_LOGIC;
               en  : in STD_LOGIC;
               led : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Sygnały wewnętrzne
    signal clk_1Hz      : STD_LOGIC;
    signal btn_prev     : STD_LOGIC := '0';
    signal clk_1hz_prev : STD_LOGIC := '0';
    signal en_signal    : STD_LOGIC;

begin

    -- Podłączenie Dzielnika Zegara
    Inst_ClockDivider: ClockDivider
        port map (
            Clk_In  => clk_100MHz,
            Clk_Out => clk_1Hz
        );

    -- Podłączenie Twojego Licznika
    Inst_Licznik: Licznik_Mod9_Neg_Plus3
        port map (
            clk => clk_100MHz,    -- Licznik też taktujemy 100MHz
            en  => en_signal,     -- Sterujemy tylko sygnałem zezwolenia (en)
            led => led
        );

    -- Proces detekcji zbocza i wyboru źródła zliczania (Multiplexer)
    process(clk_100MHz)
    begin
        if rising_edge(clk_100MHz) then
            -- Zapamiętanie poprzednich stanów do wykrycia zmiany z 0 na 1
            btn_prev <= btn_manual;
            clk_1hz_prev <= clk_1Hz;
            
            -- Domyślnie brak sygnału zliczania
            en_signal <= '0';
            
            if sw_auto = '1' then
                -- TRYB AUTOMATYCZNY: Generuj impuls 'en' tylko na narastającym zboczu zegara 1Hz
                if clk_1Hz = '1' and clk_1hz_prev = '0' then
                    en_signal <= '1';
                end if;
            else
                -- TRYB RĘCZNY: Generuj impuls 'en' tylko na narastającym zboczu przycisku
                -- (To działa jako prosty debouncer/detektor wciśnięcia)
                if btn_manual = '1' and btn_prev = '0' then
                    en_signal <= '1';
                end if;
            end if;
            
        end if;
    end process;

end Behavioral;
