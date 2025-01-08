----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/06/2025 06:44:54 PM
-- Design Name: 
-- Module Name: automat_bauturi_tb - Behavioral
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

entity automat_bauturi_tb is
end automat_bauturi_tb;

architecture tb of automat_bauturi_tb is

    component automat_bauturi is
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;

            -- Intrari pentru bancnote
            leu1          : in  std_logic;
            lei5          : in  std_logic;
            lei10         : in  std_logic;

            -- cerere_produs = int 0 - 10
            cerere_produs : in  integer range 0 to 10;

            -- cerere_rest
            cerere_rest   : in  std_logic;

            -- produs = int 0 - 10
            produs        : out integer range 0 to 10;

            leu1_rest     : out std_logic;
            lei5_rest     : out std_logic;

            -- semnal de refuz al banilor
            refuza_bani   : out std_logic
        );
    end component;

    signal clk_s          : std_logic := '0';
    signal reset_s        : std_logic := '0';

    signal leu1_s         : std_logic := '0';
    signal lei5_s         : std_logic := '0';
    signal lei10_s        : std_logic := '0';

    signal cerere_produs_s : integer range 0 to 10 := 0;
    signal cerere_rest_s   : std_logic := '0';

    signal produs_s       : integer range 0 to 10;
    signal leu1_rest_s     : std_logic;
    signal lei5_rest_s     : std_logic;
    signal refuza_bani_s   : std_logic;

    constant PERIOD : time := 10 ns;

begin

    UUT: automat_bauturi
        port map(
            clk            => clk_s,
            reset          => reset_s,
            leu1           => leu1_s,
            lei5           => lei5_s,
            lei10          => lei10_s,
            cerere_produs  => cerere_produs_s,
            cerere_rest    => cerere_rest_s,
            produs         => produs_s,
            leu1_rest      => leu1_rest_s,
            lei5_rest      => lei5_rest_s,
            refuza_bani    => refuza_bani_s
        );

    clk_process: process
    begin
        while TRUE loop
            clk_s <= '1';
            wait for PERIOD/2;
            clk_s <= '0';
            wait for PERIOD/2;
        end loop;
    end process;

    -- secventa de test
    stim_proc: process
    begin
        -- reset
        reset_s <= '1';
        wait for PERIOD;
        reset_s <= '0';
        wait for 2*PERIOD;

        -- introduc 1 leu
        leu1_s <= '1';
        wait for PERIOD;
        leu1_s <= '0';
        wait for 3*PERIOD;

        -- cer produs de 5 lei (dar este doar 1 leu)
        cerere_produs_s <= 5;
        wait for 5*PERIOD;
        cerere_produs_s <= 0;

        -- introduc inca 5 lei
        lei5_s <= '1';
        wait for PERIOD;
        lei5_s <= '0';
        wait for 3*PERIOD;

        -- cer din nou produs de 5 lei => acum sunt 6 lei
        cerere_produs_s <= 5;
        wait for 3*PERIOD;
        cerere_produs_s <= 0;

        -- introduc încă 10 lei => dar s-ar atinge 11, deci ii refuza
        lei10_s <= '1';
        wait for PERIOD;
        lei10_s <= '0';
        wait for 3*PERIOD;

        -- cer produs de 2 lei (am 1 leu in aparat => insuficient)
        cerere_produs_s <= 2;
        wait for 3*PERIOD;
        cerere_produs_s <= 0;

        -- introduc 1 leu => total 2 (suficient pt un produs de 2 lei)
        leu1_s <= '1';
        wait for PERIOD;
        leu1_s <= '0';
        wait for 2*PERIOD;

        -- cer produs de 2 lei
        cerere_produs_s <= 2;
        wait for 3*PERIOD;
        cerere_produs_s <= 0;

        -- introduc 5 lei
        lei5_s <= '1';
        wait for PERIOD;
        lei5_s <= '0';
        wait for 5*PERIOD;

        -- cer produs de 5 lei, dar am luat deja 2 produse => da rest
        cerere_produs_s <= 5;
        wait for 5*PERIOD;
        cerere_produs_s <= 0;
        wait for 5*PERIOD;
        
    end process;

end tb;
