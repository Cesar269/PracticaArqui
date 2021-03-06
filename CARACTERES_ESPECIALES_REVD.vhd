library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CARACTERES_ESPECIALES_REVD is

PORT( C1,C2,C3,C4,C5,C6,C7,C8 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
		);


end CARACTERES_ESPECIALES_REVD;

architecture Behavioral of CARACTERES_ESPECIALES_REVD is

signal char_1 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_2 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_3 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_4 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_5 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_6 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_7 : std_logic_vector(39 downto 0) := x"0000000000";
signal char_8 : std_logic_vector(39 downto 0) := x"0000000000";
 
begin

------------------------------------------------------------------
---------------CARACTERES A DIBUJAR-------------------------------

CHAR_1 <=

 "00000"&
 "00000"&	
 "00000"&
 "00000"&
 "00000"&
 "10000"&
 "10000"&
 "11100";
 
 CHAR_2 <=
 
 "00011"&
 "00101"&	
 "00111"&
 "00111"&
 "00111"&
 "00111"&
 "01111"&
 "11111";
 
 CHAR_3 <=
 
 "11110"&
 "11111"&	
 "11111"&
 "11111"&
 "10000"&
 "11110"&
 "10000"&
 "10000";
 
 CHAR_4 <=
 
 "11101"&
 "11111"&	
 "01111"&
 "00111"&
 "00011"&
 "00000"&
 "00000"&
 "00000";
 
 CHAR_5 <=
 
 "11111"&
 "11111"&	
 "11111"&
 "11111"&
 "11011"&
 "10010"&
 "10010"&
 "11011";
 
 CHAR_6 <=
 
 "11100"&
 "10100"&	
 "10000"&
 "10000"&
 "00000"&
 "00000"&
 "00000"&
 "00000";
 
 CHAR_7 <=
 
 "11111"&
 "11111"&	
 "11111"&
 "11111"&
 "11011"&
 "10010"&
 "10011"&
 "11000";
 
 CHAR_8 <=
 
 "11111"&
 "11111"&	
 "11111"&
 "11111"&
 "11011"&
 "10010"&
 "11010"&
 "00011";
 
------------------------------------------------------------------
------------------------------------------------------------------

C1 <= CHAR_1;
C2 <= CHAR_2;
C3 <= CHAR_3;
C4 <= CHAR_4;
C5 <= CHAR_5;
C6 <= CHAR_6;
C7 <= CHAR_7;
C8 <= CHAR_8;

end Behavioral;