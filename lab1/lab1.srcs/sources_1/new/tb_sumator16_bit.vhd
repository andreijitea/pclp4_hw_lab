----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 06:39:25 PM
-- Design Name: 
-- Module Name: tb_sumator16_bit - Behavioral
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

entity tb_sumator16_bit is
--  Port ( );
end tb_sumator16_bit;

architecture Behavioral of tb_sumator16_bit is
    signal a : std_logic_vector(15 downto 0);
    signal b : std_logic_vector(15 downto 0);
    signal cin : std_logic;
    signal s : std_logic_vector(15 downto 0);
    signal cout : std_logic;
begin
    
    sumator: entity work.sumator_16bit port map(a, b, cin, s, cout);
    
    teste: process
    begin
        -- a = 2, b = 1, cin = 0
        a <= "0000000000000010";
        b <= "0000000000000001";
        cin <= '0';
        wait for 20 ns;

        -- a = 10, b = 4, cin = 0
        a <= "0000000000001010";
        b <= "0000000000000100";
        cin <= '0';
        wait for 20 ns;

        -- a = 17, b = 5, cin = 0
        a <= "0000000000010001";
        b <= "0000000000000101";
        cin <= '0';
        wait for 20 ns;

        wait;

    end process;

        
    

end Behavioral;
