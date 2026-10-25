library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Detektor_Mealy_11100 is
    Port ( 
        clk    : in  STD_LOGIC;  -- Zegar systemowy
        en     : in  STD_LOGIC;  -- Impuls wczytujący bit (np. z obrotu enkodera)
        din    : in  STD_LOGIC;  -- Wprowadzany bit (1=prawo, 0=lewo)
        y_out  : out STD_LOGIC;  -- Dioda sygnalizująca wykrycie
        state  : out STD_LOGIC_VECTOR(3 downto 0) -- Numer stanu (na OLED)
    );
end Detektor_Mealy_11100;

architecture Behavioral of Detektor_Mealy_11100 is
    -- Definicja stanów maszyny
    type state_type is (S0, S1, S2, S3, S4);
    signal current_state, next_state : state_type := S0;
begin

    -- 1. Proces synchroniczny (aktualizacja stanu)
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- 2. Proces kombinacyjny (wyznaczenie stanu następnego i wyjścia Mealy)
    -- W maszynie Mealy wyjście zależy ORAZ od stanu, ORAZ od wejścia (din)
    process(current_state, din)
    begin
        -- Domyślne wartości (zapobiegają powstawaniu zatrzasków/latchy)
        next_state <= S0;
        y_out <= '0';
        
        case current_state is
            when S0 =>
                if din = '1' then next_state <= S1;
                else              next_state <= S0;
                end if;
                
            when S1 =>
                if din = '1' then next_state <= S2;
                else              next_state <= S0;
                end if;
                
            when S2 =>
                if din = '1' then next_state <= S3;
                else              next_state <= S0;
                end if;
                
            when S3 =>
                if din = '1' then next_state <= S3;
                else              next_state <= S4;
                end if;
                
            when S4 =>
                if din = '1' then 
                    next_state <= S1;
                else              
                    next_state <= S0;
                    y_out <= '1'; -- WYKRYCIE SEKWENCJI 11100 (din = 0 w stanie S4)
                end if;
                
        end case;
    end process;

    -- 3. Kodowanie stanu obecnego do wektora dla ekranu OLED
    process(current_state)
    begin
        case current_state is
            when S0 => state <= "0000"; -- 0
            when S1 => state <= "0001"; -- 1
            when S2 => state <= "0010"; -- 2
            when S3 => state <= "0011"; -- 3
            when S4 => state <= "0100"; -- 4
        end case;
    end process;

end Behavioral;
