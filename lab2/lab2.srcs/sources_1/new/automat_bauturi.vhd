----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/06/2025 05:25:13 PM
-- Design Name: 
-- Module Name: automat_bauturi - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity automat_bauturi is
    port(
        clk   : in  std_logic;
        reset : in  std_logic;

        -- Intrari pentru bancnote
        leu1  : in  std_logic;
        lei5  : in  std_logic;
        lei10 : in  std_logic;

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

    type tip_stare is (start, acc_bani, da_produs, da_rest);
    signal stare : tip_stare := start;
    
    signal total_bani    : integer range 0 to 10 := 0;
    signal cereri_produs : integer range 0 to 2 := 0;

    signal cost_mem : integer range 0 to 10 := 0;

begin

    process(clk, reset)
    begin
        if (reset = '1') then
            stare          <= start;
            total_bani     <= 0;
            cereri_produs  <= 0;
            cost_mem       <= 0;

            produs         <= 0;
            leu1_rest      <= '0';
            lei5_rest      <= '0';

        elsif rising_edge(clk) then
            produs    <= 0;
            leu1_rest <= '0';
            lei5_rest <= '0';
            refuza_bani    <= '0';

            case stare is
                -- Stare initiala
                when start =>
                    total_bani     <= 0;
                    -- cereri_produs  <= 0;
                    cost_mem       <= 0;

                    -- Verifica introducerea primei bancnote
                    if (leu1 = '1') then
                        total_bani <= 1;
                        stare      <= acc_bani;
                    elsif (lei5 = '1') then
                        total_bani <= 5;
                        stare      <= acc_bani;
                    elsif (lei10 = '1') then
                        total_bani <= 10;
                        stare      <= acc_bani;
                    else
                        stare <= start;
                    end if;


                -- Stare de colectare a banilor
                when acc_bani =>
                    -- Primeste bancnote, daca se poate (saturare la 10)
                    if (leu1 = '1') then
                        if (total_bani < 10) then
                            if (total_bani + 1) > 10 then
                                refuza_bani <= '1';
                            else
                                total_bani <= total_bani + 1;
                            end if;
                        end if;
                    elsif (lei5 = '1') then
                        if (total_bani < 10) then
                            if (total_bani + 5) > 10 then
                                refuza_bani <= '1';
                            else
                                total_bani <= total_bani + 5;
                            end if;
                        end if;
                    elsif (lei10 = '1') then
                        refuza_bani <= '1';
                    end if;

                    -- Verifica daca este cerut un produs
                    if (cerere_produs > 0) then
                        if (total_bani >= cerere_produs) then
                            cost_mem <= cerere_produs; 
                            stare    <= da_produs;     
                        else
                            stare <= acc_bani;
                        end if;

                    -- Verifica daca se cere rest
                    elsif (cerere_rest = '1') then
                        if (total_bani > 0) then
                            stare <= da_rest;
                        else
                            stare <= start;
                        end if;

                    else
                        stare <= acc_bani;
                    end if;


                -- Stare de livrare a produsului
                when da_produs =>
                    cereri_produs <= cereri_produs + 1;

                    if (cereri_produs >= 2) then
                        stare <= da_rest;
                    else
                        produs        <= cost_mem;
                        total_bani    <= total_bani - cost_mem;
                        stare <= acc_bani;
                    end if;


                -- Stare de livrare a restului
                when da_rest =>
                    if (total_bani >= 5) then
                        lei5_rest  <= '1';
                        total_bani <= total_bani - 5;
                        stare      <= da_rest;
                    elsif (total_bani > 0) then
                        leu1_rest  <= '1';
                        total_bani <= total_bani - 1;
                        stare      <= da_rest;
                    else
                        stare <= start;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;