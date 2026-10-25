library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_Level_Zad2_Ulepszone is
    Port ( 
        clk_100MHz : in STD_LOGIC;     -- Zegar główny z płyty
        ROT_A      : in STD_LOGIC;     -- Sygnał A z Rotary Encoder
        ROT_B      : in STD_LOGIC;     -- Sygnał B z Rotary Encoder
        led_detect : out STD_LOGIC;    -- Dioda sygnalizująca wykrycie 11100
        OLED_SDA   : inout STD_LOGIC;  -- Linia danych I2C
        OLED_SCL   : inout STD_LOGIC   -- Linia zegara I2C
    );
end Top_Level_Zad2_Ulepszone;

architecture Structural of Top_Level_Zad2_Ulepszone is

    -- 1. Detektor sekwencji 11100 (Twój układ z maszyną stanów)
    component Detektor_Mealy_11100 is
        Port ( clk   : in  STD_LOGIC;
               en    : in  STD_LOGIC;
               din   : in  STD_LOGIC;
               y_out : out STD_LOGIC;
               state : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    -- 2. Moduł Rotary Encoder z paczki
    component RotaryEnc is
        Port ( ROT_A : in  STD_LOGIC;
               ROT_B : in  STD_LOGIC;
               Clk   : in  STD_LOGIC;
               RotL  : out STD_LOGIC;
               RotR  : out STD_LOGIC);
    end component;

    -- 3. Moduł OLED z paczki
    component OLED_1x32 is
        Port ( Clk_100MHz : in STD_LOGIC;
               Line       : in STD_LOGIC_VECTOR (31 downto 0);
               DecPts     : in STD_LOGIC_VECTOR (7 downto 0);
               Blank      : in STD_LOGIC_VECTOR (7 downto 0);
               I2C_NACK   : out STD_LOGIC;
               OLED_SDA   : inout STD_LOGIC;
               OLED_SCL   : inout STD_LOGIC);
    end component;

    -- Sygnały wewnętrzne
    signal rot_left, rot_right : STD_LOGIC;
    signal fsm_en, fsm_din     : STD_LOGIC;
    signal current_state       : STD_LOGIC_VECTOR(3 downto 0);
    signal oled_line           : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

    -- Inicjalizacja Enkodera
    Inst_RotaryEnc: RotaryEnc port map (
        ROT_A => ROT_A,
        ROT_B => ROT_B,
        Clk   => clk_100MHz,
        RotL  => rot_left,
        RotR  => rot_right
    );

    -- Logika wprowadzania danych z Enkodera (zgodna z Twoim pomysłem na przyciski)
    -- Wygeneruj impuls 'en', gdy nastąpi obrót w dowolną stronę
    fsm_en <= rot_left or rot_right;
    -- Jeśli obrót w prawo, wpisz '1', w przeciwnym razie '0'
    fsm_din <= '1' when rot_right = '1' else '0';

    -- Inicjalizacja Detektora
    Inst_Detektor: Detektor_Mealy_11100 port map (
        clk   => clk_100MHz,
        en    => fsm_en,
        din   => fsm_din,
        y_out => led_detect,
        state => current_state
    );

    -- Przygotowanie wektora dla OLED (najmłodsze 4 bity to stan detektora)
    oled_line(3 downto 0) <= current_state;

    -- Inicjalizacja Ekranu OLED
    Inst_OLED: OLED_1x32 port map (
        Clk_100MHz => clk_100MHz,
        Line       => oled_line,
        DecPts     => "00000000", 
        Blank      => "11111110", -- Wygaszenie wszystkiego poza najmłodszą cyfrą
        I2C_NACK   => open,
        OLED_SDA   => OLED_SDA,
        OLED_SCL   => OLED_SCL
    );

end Structural;
