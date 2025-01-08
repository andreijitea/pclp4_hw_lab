library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity automat_bauturi is
    port(
        clk           : in  std_logic;
        reset         : in  std_logic;

        -- Intrari pentru bancnote
        leu1          : in  std_logic;
        lei5          : in  std_logic;
        lei10         : in  std_logic;

        -- cerere_produs = int 0 - 10
        --   0 => clientul nu cere produs
        --   n > 0 => clientul cere produs, pretul fiind 'n' lei
        cerere_produs : in  integer range 0 to 10;

        -- cerere_rest => daca e '1', clientul doreste restul
        cerere_rest   : in  std_logic;

        -- produs = int 0 - 10
        --   0 => automatul nu da produs
        --   n > 0 => automatul a dat un produs la pretul 'n' lei
        produs        : out integer range 0 to 10;

        leu1_rest     : out std_logic;
        lei5_rest     : out std_logic;

        -- 1 => automatul refuza banii (saturare la 10 lei)
        refuza_bani   : out std_logic
    );
end automat_bauturi;

architecture Behavioral of automat_bauturi is

    -- Definitii pentru stari
    type tip_stare is (start, acc_bani, da_produs, da_rest);
    signal stare, next_stare : tip_stare := start;

    -- Registrii pentru stocare informatii
    signal total_bani, next_total_bani : integer range 0 to 10 := 0;
    signal cereri_produs, next_cereri_produs : integer range 0 to 2 := 0;
    signal cost_mem, next_cost_mem : integer range 0 to 10 := 0;

    -- Registrii pentru iesiri
    signal produs_reg, next_produs_reg : integer range 0 to 10 := 0;
    signal leu1_rest_reg, next_leu1_rest_reg : std_logic := '0';
    signal lei5_rest_reg, next_lei5_rest_reg : std_logic := '0';
    signal refuza_bani_reg, next_refuza_bani_reg : std_logic := '0';

begin

    produs      <= produs_reg;
    leu1_rest   <= leu1_rest_reg;
    lei5_rest   <= lei5_rest_reg;
    refuza_bani <= refuza_bani_reg;

    -- Proces secvential
    process(clk, reset)
    begin
        if reset = '1' then
            stare           <= start;
            total_bani      <= 0;
            cereri_produs   <= 0;
            cost_mem        <= 0;

            produs_reg      <= 0;
            leu1_rest_reg   <= '0';
            lei5_rest_reg   <= '0';
            refuza_bani_reg <= '0';

        elsif rising_edge(clk) then
            stare           <= next_stare;
            total_bani      <= next_total_bani;
            cereri_produs   <= next_cereri_produs;
            cost_mem        <= next_cost_mem;

            produs_reg      <= next_produs_reg;
            leu1_rest_reg   <= next_leu1_rest_reg;
            lei5_rest_reg   <= next_lei5_rest_reg;
            refuza_bani_reg <= next_refuza_bani_reg;
        end if;
    end process;

    -- Proces combinational
    process(stare, leu1, lei5, lei10, cerere_produs, cerere_rest, total_bani, cereri_produs, cost_mem)
    begin
        -- Valorile de inceput
        next_stare           <= stare;
        next_total_bani      <= total_bani;
        next_cereri_produs   <= cereri_produs;
        next_cost_mem        <= cost_mem;

        next_produs_reg      <= 0;
        next_leu1_rest_reg   <= '0';
        next_lei5_rest_reg   <= '0';
        next_refuza_bani_reg <= '0';

        case stare is
            -- Stare initiala
            when start =>
                next_total_bani <= 0;
                next_cost_mem   <= 0;

                if leu1 = '1' then
                    next_total_bani <= 1;
                    next_stare      <= acc_bani;
                elsif lei5 = '1' then
                    next_total_bani <= 5;
                    next_stare      <= acc_bani;
                elsif lei10 = '1' then
                    next_total_bani <= 10;
                    next_stare      <= acc_bani;
                end if;

            -- Stare de colectare a banilor
            when acc_bani =>
                if leu1 = '1' then
                    if total_bani + 1 > 10 then
                        next_refuza_bani_reg <= '1';
                    else
                        next_total_bani <= total_bani + 1;
                    end if;
                elsif lei5 = '1' then
                    if total_bani + 5 > 10 then
                        next_refuza_bani_reg <= '1';
                    else
                        next_total_bani <= total_bani + 5;
                    end if;
                elsif lei10 = '1' then
                    next_refuza_bani_reg <= '1';
                end if;

                if cerere_produs > 0 then
                    if total_bani >= cerere_produs then
                        next_cost_mem <= cerere_produs;
                        next_stare    <= da_produs;
                    end if;
                elsif cerere_rest = '1' then
                    if total_bani > 0 then
                        next_stare <= da_rest;
                    else
                        next_stare <= start;
                    end if;
                end if;

            -- Stare de livrare a produsului
            when da_produs =>
                next_cereri_produs <= cereri_produs + 1;

                if cereri_produs >= 2 then
                    next_stare <= da_rest;
                else
                    next_produs_reg   <= cost_mem;
                    next_total_bani   <= total_bani - cost_mem;
                    next_stare        <= acc_bani;
                end if;

            -- Stare de livrare a restului
            when da_rest =>
                if total_bani >= 5 then
                    next_lei5_rest_reg <= '1';
                    next_total_bani    <= total_bani - 5;
                    next_stare         <= da_rest;
                elsif total_bani > 0 then
                    next_leu1_rest_reg <= '1';
                    next_total_bani    <= total_bani - 1;
                    next_stare         <= da_rest;
                else
                    next_stare <= start;
                end if;

            when others =>
                next_stare <= start;
        end case;
    end process;

end Behavioral;
