----------------------------------------------------------------------------------------------------------------------------------------------
--Programa:  Libreria de Conversión de número de 4 bits a su valor en código 7 segmentos

--Autores:  Alvarado Sandoval Alberto
--			  	García Guadalupe
-- 			Rios Rebollar Victor
-- Fecha:   22/Mar/2021

-----------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package LV_TO_7SEG is
	
	procedure CONV_LV_7SEG
		(	
			signal ent: in std_logic_vector(3 downto 0);				--Declaracion de señales
			signal sal: out std_logic_vector(6 downto 0)
		);
end package;


package body  LV_TO_7SEG is 
	procedure CONV_LV_7SEG											--Deficicion de proceso converit Logic Vector a codigo 7 seg.
		(	
			signal ent: in std_logic_vector(3 downto 0);
			signal sal: out std_logic_vector(6 downto 0)
		) is
		
	begin	
												
																							--Entra 0010 sale 2		--  
																							--Entra 0011 sale 3		--  ---0---
																							--Entra 0100 sale 4		--  |     |
																							--Entra 0101 sale 5		--  5	    1
																							--Entra 0110 sale 6		--  |	  	 |
																							--Entra 0111 sale 7		--  ---6---
																							--Entra 1000 sale 8		--  |	    |
																							--Entra 1001 sale 9		--  4	    2
																							--Entra 1010 sale A		--  |	    |
																							--Entra 1011 sale B		--  ---3---
																							--Entra 1100 sale C		--
																							--Entra 1101 sale D
																							--Entra 1110 sale E
																							--Entra 1111 sale F
										
										
			case ent is	
				when "0000" =>												--Entra 0000 sale x30 = '0'
					sal <= "1000000";
					
				when "0001" =>												--Entra 0001 sale x31 = '1'
					sal <= "1111001";
				
				when "0010" =>												--Entra 0010 sale x32 = '2'
					sal <= "0100100";		
				
				when "0011" =>												--Entra 0011 sale x33 = '3'
					sal <= "0110000";
				
				when "0100" =>												--Entra 0100 sale x34 = '4'
					sal <= "0011001";
					
				when "0101" =>												--Entra 0101 sale x35 = '5'
					sal <= "0010010";
				
				when "0110" =>
					sal <= "0000010";
					
				when "0111" =>
					sal <= "1111000";
					
				when "1000" =>
					sal <= "0000000";											--Así sucesivamente hasta el 9
						
				when "1001" =>										--Entra 1001 sale x39 = '9'
					sal <= "0011000";
					
				
				when "1010" =>											--Entra 1010 sale x41 = 'A'
					sal <= "0001000";
				
				
				when "1011" =>											--Entra 1011 sale x42 = 'B'
					sal <= "0000011";
					
				
				when "1100" =>											--Entra 1100 sale x43 = 'C'
					sal <= "1000110";
				
				when "1101" =>											--Entra 1101 sale x44 = 'D'
					sal <= "0100001";
					
				
				when "1110" =>											--Entra 1110 sale x45 = 'E'
					sal <= "0000110";
				
				
				when "1111" =>											--Entra 1111 sale x46 = 'F'
					sal <= "0001110";
				
				when others =>
					sal <= (others=>'1');
			
			end case;
					
	end procedure;
	
end package body;