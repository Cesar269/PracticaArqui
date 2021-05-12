
-----------------------------------------------------------------------------------------------------------------------------------------------
--Programa:  Libreria de Unidad Aritmetico Logica
--Autores:  Alvarado Sandoval Alberto
--			  	García Guadalupe
-- 			Rios Rebollar Victor
-- Fecha:   22/Mar/2021

-----------------------------------------------------------------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;												--Declaración de las librerías
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

package ALU is 
	signal aux: std_logic_vector(7 downto 0);
	constant zero: std_logic_vector(7 downto 0) := (others=>'0');
	constant full: std_logic_vector(7 downto 0) := "11111111";
	
-----------------------------------------------------------------------------------------------------------------------------------------------
	
--																	Declaración de funciones y entradas

-----------------------------------------------------------------------------------------------------------------------------------------------
	
	procedure fSUM(signal ac: inout std_logic_vector(15 downto 0);					--Funcion SUMA
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	
	procedure fRES(signal ac: inout std_logic_vector(15 downto 0);					--Funcion RESTA
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
						
	procedure fMUL(signal ac: inout std_logic_vector(15 downto 0);					--Funcion MULTIPLICACION
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fDIV(signal ac: inout std_logic_vector(15 downto 0);					--Funcion DIVISION
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fAND(signal ac: inout std_logic_vector(15 downto 0);					--Funcion AND
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fuOR(signal ac: inout std_logic_vector(15 downto 0);					--Funcion OR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
						
	procedure fNAND(signal ac: inout std_logic_vector(15 downto 0);				--Funcion NAND
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fNOR(signal ac: inout std_logic_vector(15 downto 0);					--Funcion NOR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fNOTA(signal ac: inout std_logic_vector(15 downto 0);				--Funcion NOT A
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fNOTB(signal ac: inout std_logic_vector(15 downto 0);				--Funcion NOT B
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fXOR(signal ac: inout std_logic_vector(15 downto 0);					--Funcion XOR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
						
	procedure fXNOR(signal ac: inout std_logic_vector(15 downto 0);					--Funcion XNOR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fIFA(signal ac: inout std_logic_vector(15 downto 0);					--Funcion IF A
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
	procedure fIFB(signal ac: inout std_logic_vector(15 downto 0);					--Funcion IF B
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						);
						
end ALU;


-----------------------------------------------------------------------------------------------------------------------------------------------

--																COMPORTAMIENTO DE LAS FUNCIONES

-----------------------------------------------------------------------------------------------------------------------------------------------P



package body ALU is  

	procedure fSUM(signal ac: inout std_logic_vector(15 downto 0);								--Operacion Suma
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin	
				band <= "000";																					--Reiniciamos la bandera
				
				aux <= ac(7 downto 0);
				ac <= std_logic_vector("00000000" &	signed(ent) + signed(aux)); 				--Sumamos los dos vectores
				
				
				if(ac = "0000000000000000") then	 														--Activamos la bandera zero si es cero
					band(0) <= '1';
				
				elsif(ac > "0000000011111111") then														--Activamos la bandera desborde si es mayor al maximo
				
					band(1) <= '1';
					ac <= (others => '0');																	--Vaciamos AL
				
				end if;
				
				
	end procedure;
	
	
	procedure fRES(signal ac: inout std_logic_vector(15 downto 0);								--Operacion Resta
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin	
	
				band <= "000";   																				-- reiniciamos la bandera
					
				aux <= ac(7 downto 0);	
				ac <= std_logic_vector("00000000" & signed(aux) - signed(ent));					--restamos la entrada al ocumulador
				
				if(ac = "0000000000000000") then	 														--Activamos la bandera zero si es cero
					band(0) <= '1';
				
				elsif(ac < "0000000000000000") then	 --Activamos la bandera zero si es cero
				
					band(2) <= '1';
				end if;
				
	end procedure;
				
				
	procedure fMUL(signal ac: inout std_logic_vector(15 downto 0);								--Operacion MULTIPLICACION
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin	
				aux <= ac(7 downto 0);
				band <= "000";																					--Reiniciamos las banderas
				ac <=  std_logic_vector(signed(ent) * signed(aux));
				
	end procedure;
				
	procedure fDIV(signal ac: inout std_logic_vector(15 downto 0);
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
	
				band <= "000";
				
				aux <= ac(7 downto 0);
				ac <=  std_logic_vector("00000000" &	signed(aux) / signed(ent)); 			--Dividimos en acumulador entre la entrada
	
	end procedure;
					
	procedure fAND(signal ac: inout std_logic_vector(15 downto 0);
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin			
			band <= "000";																						--Apagamos la bandera
			aux <= ac(7 downto 0); 
			ac <=  std_logic_vector("00000000" & signed(ent) and signed(aux));				--Operacion AND
	
	end procedure;
	
	--De aquí en adelante noto inecesario seguir comentando, todas las funciones hacen lo mismo, apagan las banderas, cargan un operando
	--auxiliar y hacen la operacion logica
	
	procedure fuOR(signal ac: inout std_logic_vector(15 downto 0);								--Operacion OR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin	
			band <= "000";											
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(ent) or signed(aux));
	
	end procedure;
						
	procedure fNAND(signal ac: inout std_logic_vector(15 downto 0);								--Operacion NAND
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(ent) nand signed(aux));
	
	end procedure;					
	procedure fNOR(signal ac: inout std_logic_vector(15 downto 0);								--Operacion NOR
						signal ent: in std_logic_vector(7 downto 0);	
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(ent) nor signed(aux));
	
	end procedure;
	procedure fNOTA(signal ac: inout std_logic_vector(15 downto 0);								--Operacion NOTA
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & not(signed(ent)));
	
	end procedure;
	procedure fNOTB(signal ac: inout std_logic_vector(15 downto 0);								--Operacion NOTB
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & not(aux));
	
	end procedure;
	procedure fXOR(signal ac: inout std_logic_vector(15 downto 0);								--Operacion XOR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(ent) xor signed(aux));
	
	end procedure;
						
	procedure fXNOR(signal ac: inout std_logic_vector(15 downto 0);								--Operacion XNOR
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(ent) xnor signed(aux));
	
	end procedure;
	procedure fIFA(signal ac: inout std_logic_vector(15 downto 0);								--Operacion IFA
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			ac <=  std_logic_vector("00000000" & signed(ent));
	
	end procedure;
						
	procedure fIFB(signal ac: inout std_logic_vector(15 downto 0);								--Operacion IFB
						signal ent: in std_logic_vector(7 downto 0);
						signal band: out std_logic_vector(2 downto 0)
						) is
	begin
			band <= "000";
			aux <= ac(7 downto 0);
			ac <=  std_logic_vector("00000000" & signed(aux));
	
	end procedure;
	
end package body;