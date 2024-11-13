----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 04:37:35 PM
-- Design Name: 
-- Module Name: uat - Behavioral
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

entity uat is
    Port(p : in STD_LOGIC_VECTOR(3 downto 0);
         g : in STD_LOGIC_VECTOR(3 downto 0);
         cin : in STD_LOGIC;
         c : out STD_LOGIC_VECTOR(3 downto 0);
         Pp : out STD_LOGIC;
         Gg : out STD_LOGIC);
end uat;

architecture Behavioral of uat is
begin
    c(0) <= g(0) or (p(0) and cin);
    c(1) <= g(1) or (p(1) and g(0)) or (p(1) and p(0) and cin);
    c(2) <= g(2) or (p(2) and g(1)) or (p(2) and p(1) and g(0)) or (p(2) and p(1) and p(0) and cin);
    c(3) <= g(3) or (p(3) and g(2)) or (p(3) and p(2) and g(1)) or (p(3) and p(2) and p(1) and g(0)) or (p(3) and p(2) and p(1) and p(0) and cin);
    Pp <= p(3) and p(2) and p(1) and p(0);
    Gg <= g(3) or (p(3) and g(2)) or (p(3) and p(2) and g(1)) or (p(3) and p(2) and p(1) and g(0));
end Behavioral;
