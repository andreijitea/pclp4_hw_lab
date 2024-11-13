----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 06:12:03 PM
-- Design Name: 
-- Module Name: sumator_16bit - Behavioral
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

entity sumator_16bit is
    Port(a : in std_logic_vector(15 downto 0);
         b : in std_logic_vector (15 downto 0);
         cin : in std_logic;
         s : out std_logic_vector (15 downto 0);
         cout: out std_logic;
         Pp : out std_logic;
         Gg : out std_logic);
end sumator_16bit;

architecture Behavioral of sumator_16bit is
    signal p : STD_LOGIC_VECTOR(3 downto 0);
    signal g : STD_LOGIC_VECTOR(3 downto 0);
    signal c : STD_LOGIC_VECTOR(3 downto 0);
begin
    uat0: entity work.uat Port map(p, g, cin, c, Pp, Gg);

    sumator0: entity work.sumator_4bit port map(a(3 downto 0), b(3 downto 0), cin, s(3 downto 0), p(0), g(0));
    sumator1: entity work.sumator_4bit port map(a(7 downto 4), b(7 downto 4), c(0), s(7 downto 4), p(1), g(1));
    sumator2: entity work.sumator_4bit port map(a(11 downto 8), b(11 downto 8), c(1), s(11 downto 8), p(2), g(2));
    sumator3: entity work.sumator_4bit port map(a(15 downto 12), b(15 downto 12), c(2), s(15 downto 12), p(3), g(3));
    
    cout <= c(3);

end Behavioral;
