----------------------------------------------------------------------------------------------------------------------------------------------
--Programa:  Libreria de Conversión de número de 4 bits a su valor hexadecimal en ASCII

--Autores:  Alvarado Sandoval Alberto
--			  	García Guadalupe
-- 			Rios Rebollar Victor
-- Fecha:   22/Mar/2021

-----------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package LV_TO_HEX_CHAR is
	
	procedure CONV_LV_HEX
		(	
			signal ent: in std_logic_vector(3 downto 0);				--Declaracion de señales
			signal sal: out std_logic_vector(7 downto 0)
		);
end package;


package body  LV_TO_HEX_CHAR is 
	procedure CONV_LV_HEX											--Deficicion de proceso converit Logic Vector a Hexadecimal ASCII
		(	
			signal ent: in std_logic_vector(3 downto 0);
			signal sal: out std_logic_vector(7 downto 0)
		) is
		
	begin	
			case ent is	
				when "0000" =>												--Entra 0000 sale x30 = '0'
					sal <= x"30";
					
				when "0001" =>												--Entra 0001 sale x31 = '1'
					sal <= x"31";
				
				when "0010" =>												--Entra 0010 sale x32 = '2'
					sal <= x"32";		
				
				when "0011" =>												--Entra 0011 sale x33 = '3'
					sal <= x"33";
				
				when "0100" =>												--Entra 0100 sale x34 = '4'
					sal <= x"34";
					
				when "0101" =>												--Entra 0101 sale x35 = '5'
					sal <= x"35";
				
				when "0110" =>
					sal <= x"36";
					
				when "0111" =>
					sal <= x"37";
					
				when "1000" =>
					sal <= x"38";											--Así sucesivamente hasta el 9
						
				when "1001" =>										--Entra 1001 sale x39 = '9'
					sal <= x"39";
					
				
				when "1010" =>											--Entra 1010 sale x41 = 'A'
					sal <= x"41";
				
				
				when "1011" =>											--Entra 1011 sale x42 = 'B'
					sal <= x"42";
					
				
				when "1100" =>											--Entra 1100 sale x43 = 'C'
					sal <= x"43";
				
				when "1101" =>											--Entra 1101 sale x44 = 'D'
					sal <= x"44";
					
				
				when "1110" =>											--Entra 1110 sale x45 = 'E'
					sal <= x"45";
				
				
				when "1111" =>											--Entra 1111 sale x46 = 'F'
					sal <= x"46";
				
				when others =>
					sal <= x"20";
			
			end case;
	end procedure;
	
end package body;