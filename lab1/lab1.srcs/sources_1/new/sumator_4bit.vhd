----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 04:38:35 PM
-- Design Name: 
-- Module Name: sumator_4bit - Behavioral
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

entity sumator_4bit is
    Port(a : in STD_LOGIC_VECTOR(3 downto 0);
         b : in STD_LOGIC_VECTOR(3 downto 0);
         cin : in STD_LOGIC;
         s : out STD_LOGIC_VECTOR(3 downto 0);
         cout : out STD_LOGIC;
         Pp : out STD_LOGIC;
         Gg : out STD_LOGIC);
end sumator_4bit;

architecture Behavioral of sumator_4bit is
    signal p : STD_LOGIC_VECTOR(3 downto 0);
    signal g : STD_LOGIC_VECTOR(3 downto 0);
    signal c : STD_LOGIC_VECTOR(3 downto 0);
begin
    uat0: entity work.uat Port map(p, g, cin, c, Pp, Gg);

    sumator0: entity work.sumator_1bit port map(a(0), b(0), cin, s(0), p(0), g(0));
    sumator1: entity work.sumator_1bit port map(a(1), b(1), c(0), s(1), p(1), g(1));
    sumator2: entity work.sumator_1bit port map(a(2), b(2), c(1), s(2), p(2), g(2));
    sumator3: entity work.sumator_1bit port map(a(3), b(3), c(2), s(3), p(3), g(3));

    cout <= c(3);
end Behavioral;
