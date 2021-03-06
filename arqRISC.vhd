------------------------------------------------------------------------------------------------------------------------------------------------

--																	DECLARACION DE LAS LIBRERIAS

------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;										--Libreria principal de la IEEE para VHDL
use ieee.std_logic_1164.all;					--Libreria para el uso de arreglos lógicos
use ieee.std_logic_signed.all;				--Libreria para uso de operaciones numéricas con signos
use ieee.numeric_std.all;						--Libreria para uso de operaciones aritmétocas y numéricas
use work.ALU.all;									--Librería que contiene las operaciones de la Unidad Aritmetico Logica
use work.COMANDOS_LCD_REVD.all;				--Libreria que contiene instrucciones para controlar el LCD
use work.LV_TO_HEX_CHAR.all;					--Libreria que convierte números a su valor en ASCII
use work.LV_TO_7SEG.all;
------------------------------------------------------------------------------------------------------------------------------------------------

--													DECLARACION DE LA ENTIDAD PRINCIPAL, ENTRADAS Y SALIDAS

------------------------------------------------------------------------------------------------------------------------------------------------



entity arqRISC is 
	
	GENERIC(
			FPGA_CLK : INTEGER := 100_000_000						--Ciclo de reloj para sincronizar con el procesador LCD
	);

	port(
		clk, clr, exe: in std_logic;									--Señal de reloj y señal de reset
		bus_instruccion: in std_logic_vector(4 downto 0);		--Bus de instrucción para seleccionar lo que vamos a hacer
		
		ent: in std_logic_vector(7 downto 0);						--Entrada de datos
		bus_datos: inout std_logic_vector(7 downto 0); 			--Bus de datos
		
		
		band: out std_logic_vector(2 downto 0);					--Vector bandera para cero, desborde y negativo
		bus_dir: out std_logic_vector(12 downto 0);				--Bus de direccion
		bus_ctrl: out std_logic_vector(11 downto 0);				--Bus de Control
		
		LCD_ON : OUT STD_LOGIC;											--Bit que enciende el LCD
		
		RS  : OUT STD_LOGIC;												--Señales para funcionamiento del LCD												
		RW	 : OUT STD_LOGIC;							
		ENA : OUT STD_LOGIC;
		DATA_LCD: out std_logic_vector(7 downto 0);				--Salida de datos a display LCD
		
		DISP: OUT STD_LOGIC_VECTOR(55 downto 0)
);

end arqRISC;


------------------------------------------------------------------------------------------------------------------------------------------------

--															Arquitectura y comportamiento 
--																	Del Proyecto

------------------------------------------------------------------------------------------------------------------------------------------------


architecture Practica2 of arqRISC is
	
	CONSTANT NUM_INSTRUCCIONES : INTEGER := 24; 										--INDICAR EL NÚMERO DE INSTRUCCIONES PARA LA LCD
	
	signal AX: std_logic_vector(15 downto 0) := (others=>'0');  				--Registro Acumulador AX, parte alta y baja
	signal CPrograma: std_logic_vector(7 downto 0) := (others=>'0'); 			--Contador de programa
	signal IX: std_logic_vector(12 downto 0) := (others=>'0'); 					--Registro Índice
	signal insta: std_logic_vector(4 downto 0) := (others=>'0'); 				--Zero
	signal aux: std_logic_vector(7 downto 0) := (others=>'0');					--Auxiliar
	
	signal dispaux: std_logic_vector(3 downto 0) := (others=>'0');
	
	component PROCESADOR_LCD_REVD is														--Componente procesador LCD, de la librería para el LCD
																									
		GENERIC(																					--De nuevo declaramos el relój a la misma frecuencia
					FPGA_CLK : INTEGER := 100_000_000;									--Inicializamos el numero de instrucciones
					NUM_INST : INTEGER := 1												
		);																							
																									
		PORT( CLK 				 : IN  STD_LOGIC;											--Declaracion de señales para el uso del procesador LCD
				VECTOR_MEM 		 : IN  STD_LOGIC_VECTOR(8  DOWNTO 0);				
				C1A,C2A,C3A,C4A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);				
				C5A,C6A,C7A,C8A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
				RS 				 : OUT STD_LOGIC;											
				RW 				 : OUT STD_LOGIC;											
				ENA 				 : OUT STD_LOGIC;											
				BD_LCD 			 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);			   
				DATA 				 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);				
				DIR_MEM 			 : OUT INTEGER RANGE 0 TO NUM_INSTRUCCIONES;
				exes,clrs        : IN STD_LOGIC
			);																						
																									
		end component PROCESADOR_LCD_REVD;												
																									
		COMPONENT CARACTERES_ESPECIALES_REVD is										--Componente que inserta caracteres especiales en el LCD	
																									--Incluido en la libreria del LCD
		PORT( C1,C2,C3,C4 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);					
				C5,C6,C7,C8 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)						
			 );																					
																									
		end COMPONENT CARACTERES_ESPECIALES_REVD;										
																									
		CONSTANT CHAR1 : INTEGER := 1;													
		CONSTANT CHAR2 : INTEGER := 2;													
		CONSTANT CHAR3 : INTEGER := 3;													
		CONSTANT CHAR4 : INTEGER := 4;																
		CONSTANT CHAR5 : INTEGER := 5;																
		CONSTANT CHAR6 : INTEGER := 6;																
		CONSTANT CHAR7 : INTEGER := 7;																
		CONSTANT CHAR8 : INTEGER := 8;																
																												
		type ram is array (0 to  NUM_INSTRUCCIONES) of std_logic_vector(8 downto 0); 	--Tipo RAM que permite acceder a direcciones de memoria
																												--correspondientes a cuadros del LCD
		
		
		signal INST : ram := (others => (others => '0'));										--Variable instruccion del tipo RAM 
																												--A la que le asignaremos instrucciones secuencialmente
																												--Para mostrar caracteres en los diversos cuadros del	LCD
																												
																												
		signal blcd 			  : std_logic_vector(7 downto 0):= (others => '0');		--Señales necesarias para el funcionamiento del Procesador
		signal vector_mem 	  : STD_LOGIC_VECTOR(8  DOWNTO 0) := (others => '0');		--LCD y los caracteres especiales
		signal c1s,c2s,c3s,c4s : std_logic_vector(39 downto 0) := (others => '0');		
		signal c5s,c6s,c7s,c8s : std_logic_vector(39 downto 0) := (others => '0'); 	
		signal dir_mem 		  : integer range 0 to NUM_INSTRUCCIONES := 0;	
		
		signal bienvenida      : std_logic := '1';   											--Bandera de estado de
																												--bienvenida en el LCD
	begin
	
	
	u1: PROCESADOR_LCD_REVD													 							--Asignacion y mapeo de las señales del procesador LCD
		GENERIC map( FPGA_CLK => FPGA_CLK,									 						--y LA ENTIDAD DE CARACTERES ESPECIALES
						 NUM_INST => NUM_INSTRUCCIONES )						 
																						 
		PORT map(CLK,VECTOR_MEM,C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S,RS,
					RW,ENA,BLCD,DATA_LCD,DIR_MEM,exe,clr);						 
																						 
	U2 : CARACTERES_ESPECIALES_REVD 										 
		PORT MAP(C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S);				 		 																					 
						  VECTOR_MEM <= INST(DIR_MEM);		
						  
						  
------------------------------------------------------------------------------------------------------------------------------------------------	
--																	Comportamiento principal						
				------------------------------------------------------------------------------------------------------------------------------------------------
			
			
	process(clk, clr, bus_instruccion, ent)				
	
	begin
	
		LCD_ON <= '1';														--Encendemos el LCD
		
		if(clr = '0') then 												--Reset activado
			
			AX <= (others=>'0');	            						--Cuando esto pasa limpiamos indice, acumulador, el contador
			IX <= (others=>'0');
			CPrograma <= (others=>'0');								-- Activamos de nuevo la bandera de bienvenida del LCD
			bienvenida <= '1';
			INST <= (others => (others => '0'));					--Reiniciamos la instrucción y direcciones de los cuadros LSD XD
			DISP <= (others => '1');					--Apagamos los displays de 7 segmentos
			
			
		elsif (clk'event 	and clk = '1') then                  --Si no hay reset y hay un '1' en la señal de reloj
		
		
			if(bienvenida = '1') then									--Si es el inicio y aún no se han metido instrucciones la pantalla mostrará
				
				bienvenida <= '0';										--un mensaje de bienvenida
				
				DISP <= (others => '1');					--Apagamos los displays de 7 segmentos
				
				
      ------Bloque de codificacion de mensaje de bienvenida en el LCD-----------------------------
			
				INST(0) <= LCD_INI("00");								--Inicializamos el LCD
				INST(1) <= LIMPIAR_PANTALLA('1');
				INST(2) <= CHAR_ASCII(x"20");
				INST(3) <= CHAR_ASCII(x"20");
				INST(4) <= CHAR_ASCII(x"20");
				INST(5) <= CHAR_ASCII(x"20");
				INST(6) <= CHAR(MP);
				INST(7) <= CHAR(MR);
				INST(8) <= CHAR(MA);
				INST(9) <= CHAR(MC);
				INST(10) <= CHAR(MT);
				INST(11) <= CHAR(MI);
				INST(12) <= CHAR(MC);
				INST(13) <= CHAR(MA);
				INST(14) <= CHAR_ASCII(x"20");
				INST(15) <= CHAR_ASCII(x"31");
				INST(16) <= CODIGO_FIN(1);
				
				
				
			elsif exe = '0' then  										--Botón de ejución pulsado
				
				INST <= (others => (others => '0'));				--Reiniciamos las instrucciones para que no se sobrepongan
				
				
				case bus_instruccion is   								--Seleccionamos cada instruccion por un código espescifico
					
					
				-------------------------------------------------------------------------------------------------------					
					when "00000" =>													--00   Suma aritmetica
					
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MA);											----------------------------------------
						INST(3) <= CHAR(MD);														
						INST(4) <= CHAR(MD);											--Leyenda: SUM AL,ENT
						INST(5) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(7 downto 4), aux);						--         00 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(7) <= CHAR_ASCII(aux);								----------------------------------------
						INST(8) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"30");
						
						fSUM(AX, ent, band);										--Llamamos la funcion suma de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(7 downto 4), aux);
						INST(15) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
							
							
						CPrograma <= Cprograma+1;							--Incrementamos el contador de programa
					--------------------------------------------------------------------------------------------------------------------------	
		
					when "00001" =>													-- 01 Resta
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(S);
						INST(3) <= CHAR(MU);											---------------------------------------
						INST(4) <= CHAR(MB);
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: SUB AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--   		  01 AL	
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						----------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"31");
						
						fRES(AX, ent, band);										--Llamamos la funcion resta de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(7 downto 4), aux);
						INST(15) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
						
						CPrograma <= Cprograma+1;
						
					--------------------------------------------------------------------------------------------------------------------------	
						
					
					when "00010" =>													-- 02 Multiplicación
					
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MM);
						INST(3) <= CHAR(MU);											--------------------------------------
						INST(4) <= CHAR(ML);		
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: MUL AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  02 AX
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"32");
						
						fMUL(AX, ent, band);										--Llamamos la funcion multiplicacion de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");						
						CONV_LV_HEX(AX(15 downto 12), aux);					--Esta funcion y todas sus llamadas
						INST(15) <= CHAR_ASCII(aux);							--convierten un número de 4 bits a su valor ASCII
						CONV_LV_HEX(AX(11 downto 8), aux);
						INST(16) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(7 downto 4), aux);
						INST(17) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(18) <= CHAR_ASCII(aux);
						INST(19) <= CODIGO_FIN(1);
						
						CPrograma <= Cprograma+1;
						
					--------------------------------------------------------------------------------------------------------------------------		
					when "00011" =>													-- 03 Division
						
						
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MD);
						INST(3) <= CHAR(MI);											--------------------------------------
						INST(4) <= CHAR(MV);		
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: DIV AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  03 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"33");
						
						fDIV(AX, ent, band);										--Llamamos la funcion division de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(15) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					
					--------------------------------------------------------------------------------------------------------------------------	
					when "00100" =>													-- 04 AND
						
						
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MA);
						INST(3) <= CHAR(MN);											--------------------------------------
						INST(4) <= CHAR(MD);		
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: AND AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  04 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"34");
						
						fAND(AX, ent, band);										--Llamamos la funcion AND de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(15) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------	
					
					when "00101" =>													-- 05 OR
						 
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MO);
						INST(3) <= CHAR(MR);											--------------------------------------	
						INST(4) <= CHAR_ASCII(x"20");								--Leyenda: OR AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  05 AL
						INST(5) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(6) <= CHAR_ASCII(aux);
						INST(7) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(8) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(9) <= CHAR_ASCII(aux);
						INST(10) <=	POS(2,1);
						INST(11) <= CHAR_ASCII(x"30");
						INST(12) <= CHAR_ASCII(x"35");
						
						fuOR(AX, ent, band);										--Llamamos la funcion OR de la libreria
						
						INST(13) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(14) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(15) <= CHAR_ASCII(aux);
						INST(16) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------	
					
					when "00110" =>			
																							-- 06 NAND
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MN);
						INST(3) <= CHAR(MA);											--------------------------------------
						INST(4) <= CHAR(MN);
						INST(5) <= CHAR(MN);		
						INST(6) <= CHAR_ASCII(x"20");								--Leyenda: NAND AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  06 AL
						INST(7) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(8) <= CHAR_ASCII(aux);
						INST(9) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(10) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(11) <= CHAR_ASCII(aux);
						INST(12) <=	POS(2,1);
						INST(13) <= CHAR_ASCII(x"30");
						INST(14) <= CHAR_ASCII(x"36");
						
						fNAND(AX, ent, band);										--Llamamos la funcion NAND de la libreria
						
						INST(15) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(16) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(17) <= CHAR_ASCII(aux);
						INST(18) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------	
					when "00111" =>													-- 07 NOR
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MN);
						INST(3) <= CHAR(MO);											--------------------------------------
						INST(4) <= CHAR(MR);	
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: NOR AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  07 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"30");
						INST(13) <= CHAR_ASCII(x"37");
						
						fNOR(AX, ent, band);										--Llamamos la funcion NOR de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(15) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------	
						
					when "01000" =>													-- 08 NOT A
						
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MN);
						INST(3) <= CHAR(MO);											--------------------------------------
						INST(4) <= CHAR(MT);		
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: NOT AL
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  08 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <=	POS(2,1);
						INST(9) <= CHAR_ASCII(x"30");
						INST(10) <= CHAR_ASCII(x"38");
						
						fNOTA(AX, ent, band);										--Llamamos la funcion NOT A de la libreria
						
						INST(11) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(12) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(13) <= CHAR_ASCII(aux);
						INST(14) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa	
						
					--------------------------------------------------------------------------------------------------------------------------	
						
					when "01001" =>													-- 09 NOT B
						
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MN);
						INST(3) <= CHAR(MO);											--------------------------------------
						INST(4) <= CHAR(MT);		
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: NOT ENT
						CONV_LV_HEX(ent(7 downto 4), aux);						--			  09 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <=	POS(2,1);
						INST(9) <= CHAR_ASCII(x"30");
						INST(10) <= CHAR_ASCII(x"39");
						
						fNOTB(AX, ent, band);										--Llamamos la funcion NOT B de la libreria
						
						INST(11) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(12) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(13) <= CHAR_ASCII(aux);
						INST(14) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------		
					when "01010" =>													-- 10 XOR
						
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MX);
						INST(3) <= CHAR(MO);											--------------------------------------
						INST(4) <= CHAR(MR);	
						INST(5) <= CHAR_ASCII(x"20");								--Leyenda: XOR AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  10 AL
						INST(6) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(7) <= CHAR_ASCII(aux);
						INST(8) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <=	POS(2,1);
						INST(12) <= CHAR_ASCII(x"31");
						INST(13) <= CHAR_ASCII(x"30");
						
						fXOR(AX, ent, band);										--Llamamos la funcion XOR de la libreria
						
						INST(14) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(15) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						INST(17) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------		
						
					when "01011" =>													-- 11 XNOR
					
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MX);
						INST(3) <= CHAR(MN);											--------------------------------------
						INST(4) <= CHAR(MO);
						INST(5) <= CHAR(MR);		
						INST(6) <= CHAR_ASCII(x"20");								--Leyenda: XNOR AL,ENT
						CONV_LV_HEX(AX(7 downto 4), aux);						--			  11 AL
						INST(7) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);						--------------------------------------
						INST(8) <= CHAR_ASCII(aux);
						INST(9) <= CHAR_ASCII(x"2C");
						
						CONV_LV_HEX(ent(7 downto 4), aux);
						INST(10) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);
						INST(11) <= CHAR_ASCII(aux);
						INST(12) <=	POS(2,1);
						INST(13) <= CHAR_ASCII(x"31");
						INST(14) <= CHAR_ASCII(x"31");
						
						fXNOR(AX, ent, band);										--Llamamos la funcion XNOR de la libreria
						
						INST(15) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(16) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(17) <= CHAR_ASCII(aux);
						INST(18) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
						
					--------------------------------------------------------------------------------------------------------------------------		
					when "01100" =>													-- 12 IF A
						
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MI);
						INST(3) <= CHAR(MF);											--------------------------------------	
						INST(4) <= CHAR_ASCII(x"20");								--Leyenda: IF AL
						CONV_LV_HEX(ent(7 downto 4), aux);						--			  12 AL
						INST(5) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);						--------------------------------------
						INST(6) <= CHAR_ASCII(aux);
						INST(7) <=	POS(2,1);
						INST(8) <= CHAR_ASCII(x"31");
						INST(9) <= CHAR_ASCII(x"32");
						
						fIFB(AX, ent, band);										--Llamamos la funcion IF A de la libreria
						
						INST(10) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(11) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(12) <= CHAR_ASCII(aux);
						INST(13) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
					
					
					--------------------------------------------------------------------------------------------------------------------------		
						
					when "01101" =>													-- 13 IF B
					
						
						INST(0) <= LCD_INI("00");									--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');
						INST(2) <= CHAR(MI);
						INST(3) <= CHAR(MF);											--------------------------------------	
						INST(4) <= CHAR_ASCII(x"20");								--Leyenda: IF ENT
						CONV_LV_HEX(ent(7 downto 4), aux);						--			  13 AL
						INST(5) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0), aux);						--------------------------------------
						INST(6) <= CHAR_ASCII(aux);
						INST(7) <=	POS(2,1);
						INST(8) <= CHAR_ASCII(x"31");
						INST(9) <= CHAR_ASCII(x"33");
						
						fIFB(AX, ent, band);										--Llamamos la funcion IF A de la libreria
						
						INST(10) <= CHAR_ASCII(x"20");						
						
						CONV_LV_HEX(AX(7 downto 4), aux);					--Esta funcion y todas sus llamadas convierten un número
						INST(11) <= CHAR_ASCII(aux);							--En su valor ASCII
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(12) <= CHAR_ASCII(aux);
						INST(13) <= CODIGO_FIN(1);
						
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
				--------------------------------------------------------------------------------------------------------------------------	
				when "10000" =>  												-- 14 CLAX 
																					-- Limpiar el acumulador
						
						AX <= (others=>'0');         
						CPrograma <= Cprograma+1;
						
						
						
						INST(0) <= LCD_INI("00");							--Bloque de instrucciones del LCD
						INST(1) <= LIMPIAR_PANTALLA('1');				--------------------------------------	
						INST(2) <= CHAR(MC);
						INST(3) <= CHAR(ML);									--Leyenda: CLAX
						INST(4) <= CHAR(MA);									--			  14 AX
						INST(5) <= CHAR(MX);
						INST(6) <= POS(2,1);									--------------------------------------	
																					
						INST(7) <= CHAR_ASCII(x"31");
						INST(8) <= CHAR_ASCII(x"34");
						
						INST(9) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(15 downto 12),aux);				--Con esta funcion y todas sus llamadas
						INST(10) <= CHAR_ASCII(aux);						--Convertimos un numero de 4 bits en su código ASCII
						CONV_LV_HEX(AX(11 downto 8),aux);	
						INST(11) <= CHAR_ASCII(aux);
						
						CONV_LV_HEX(AX(7 downto 4),aux);
						INST(12) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0),aux);
						INST(13) <= CHAR_ASCII(aux);
						INST(14) <= CODIGO_FIN(1);
						
						CPrograma <= Cprograma+1;								--Incrementamos el contador de programa
					
					--------------------------------------------------------------------------------------------------------------------------	
						
					when "10001" =>  											-- 15 MOV AL 	
																					-- Cargamos la parte baja del acumumulador con un dato
						
						AX(7 downto 0) <= ent;								--Literalmente asignamos el dato en la parte baja del acumulador
						
						
						
						INST(0) <= LCD_INI("00");							--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');				--------------------------------------
						INST(2) <= CHAR(MM);									--Leyenda: MOV AL,ENT
						INST(3) <= CHAR(MO);									-- 		  15  AL
						INST(4) <= CHAR(MV);
						INST(5) <= CHAR_ASCII(x"20");						--------------------------------------
						INST(6) <= CHAR(MA);
						INST(7) <= CHAR(ML);
						INST(8) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4),aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0),aux);				
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <= POS(2,1);
						
						INST(12) <= CHAR_ASCII(x"31");					--Con esta funcion y todas sus llamadas
						INST(13) <= CHAR_ASCII(x"35");					--Convertimos un numero de 4 bits en su código ASCII
						
						INST(14) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(7 downto 4),aux);				
						INST(15) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						
						INST(17) <= CODIGO_FIN(1);
						
						Cprograma <= Cprograma + 1;					--Incremento en el contador de programa
					--------------------------------------------------------------------------------------------------------------------------		
						
					when "10010" =>  								-- 16 MOV AH 	
																		-- Cargamos la parte alta del acumumulador con un dato
						
						AX(15 downto 8) <= ent;								--Literalmente asignamos el dato en la parte alta del acumulador
						
						
						
						INST(0) <= LCD_INI("00");							--Bloque de instrucciones para el LCD
						INST(1) <= LIMPIAR_PANTALLA('1');				--------------------------------------
						INST(2) <= CHAR(MM);									--Leyenda: MOV AH,ENT
						INST(3) <= CHAR(MO);									-- 		  16  AH
						INST(4) <= CHAR(MV);
						INST(5) <= CHAR_ASCII(x"20");						--------------------------------------
						INST(6) <= CHAR(MA);
						INST(7) <= CHAR(MH);
						INST(8) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4),aux);
						INST(9) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0),aux);				
						INST(10) <= CHAR_ASCII(aux);
						INST(11) <= POS(2,1);
						
						INST(12) <= CHAR_ASCII(x"31");					--Con esta funcion y todas sus llamadas
						INST(13) <= CHAR_ASCII(x"36");					--Convertimos un numero de 4 bits en su código ASCII
						
						INST(14) <= CHAR_ASCII(x"20");					--(CONV_LV_HEX)
						CONV_LV_HEX(AX(7 downto 4),aux);				
						INST(15) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0), aux);
						INST(16) <= CHAR_ASCII(aux);
						
						INST(17) <= CODIGO_FIN(1);
						
						Cprograma <= Cprograma + 1;					--Incremento en el contador de programa
					--------------------------------------------------------------------------------------------------------------------------	
						
					when "10011" =>  								-- 17 MOV (AL, IX)
																		--Carga el registro indice con una 
																		--direccion de memoria y cargamos el acumumulador con el dato en dicha direccion
						
						IX <= (others=>'0');						--Limpia el registro índice							
						IX(7 downto 0) <= ent;					--Carga los primeros 8 bits del índice con la entrada de datos
						
						

						bus_ctrl(0) <= '0'; 						--Seleccionamos el banco 0 de la SDRAM							
						bus_ctrl(1) <= '0';						--Seleccionamos el banco 1 de la SDRAM		
						
						bus_ctrl(2) <= '0';						--Activa la máscara 0 de la RAM 		
						bus_ctrl(3) <= '0';						--Activa la máscara 1 de la RAM 	
						bus_ctrl(4) <= '0'; 						--Activa la máscara 2 de la RAM 	
						bus_ctrl(5) <= '0'; 						--Activa la máscara 3 de la RAM 	
						
						bus_ctrl(6) <= '1';						--Seleccionamos la fila
						bus_ctrl(7) <= '0';						--Seleccionamos la columna
						
						bus_ctrl(8) <= '1';						--Activa el Relój de la RAM
						bus_ctrl(9) <= clk;						--Conmutación de la RAM
						
						bus_ctrl(10) <= '1';						--Escritura desactivada
						bus_ctrl(11) <= '1';						--Chip enable de la RAM activado
						
						bus_dir(10) <= '1';                 --Activamos el bit de precarga
						
						bus_dir <= IX;								--Cargamos la direccion de entrada en el bus de dirección
						
						AX <= "00000000" & bus_datos;     --Cargamos la parte baja del acumulador con los datos contenidos en la direccion especificada
						
						
						
						
						INST(0) <= LCD_INI("00");							--Bloque de instrucciones del acumulador				
						INST(1) <= LIMPIAR_PANTALLA('1');				---------------------------------------------
						INST(3) <= CHAR(MM);									--Leyenda: MOV (AL, ENT)
						INST(4) <= CHAR(MO);									--			  17	AL
						INST(5) <= CHAR(MV);
						INST(6) <= CHAR_ASCII(x"20");						---------------------------------------------
						INST(7) <= CHAR_ASCII(x"28");
						INST(8) <= CHAR(MA);
						INST(9) <= CHAR(ML);
						INST(10) <= CHAR_ASCII(x"2C");
						CONV_LV_HEX(ent(7 downto 4),aux);
						INST(11) <= CHAR_ASCII(aux);
						CONV_LV_HEX(ent(3 downto 0),aux);
						INST(12) <= CHAR_ASCII(aux);
						INST(13) <= CHAR_ASCII(x"29");
						INST(14) <= POS(2,1);
						INST(15) <= CHAR_ASCII(x"31");					--Con esta funcion y todas sus llamadas
						INST(16) <= CHAR_ASCII(x"37");					--Convertimos un numero de 4 bits en su código ASCII
						
						INST(17) <= CHAR_ASCII(x"20");
						CONV_LV_HEX(AX(7 downto 4),aux);
						
						
						INST(18) <= CHAR_ASCII(aux);
						CONV_LV_HEX(AX(3 downto 0),aux);
						INST(19) <= CHAR_ASCII(aux);
						
						INST(20) <= CODIGO_FIN(1);
						
						CPrograma <= CPrograma + 1;        --Incrementamos el contador de programa
					
				
					--------------------------------------------------------------------------------------------------------------------------	
						
					when "10100" => 								-- 18 MOV  IX, AL
																		-- Cargar una direccion de memoria con la parte baja del acumulador
							
							IX(7 downto 0)<= ent;      		--Cargamos el indice con una direccion de memoria
							
						
							
							bus_ctrl(0) <= '0'; 						--Seleccionamos el banco 0 de la SDRAM							
							bus_ctrl(1) <= '0';						--Seleccionamos el banco 1 de la SDRAM		
						
							bus_ctrl(2) <= '0';						--Activa la máscara 0 de la RAM 		
							bus_ctrl(3) <= '0';						--Activa la máscara 1 de la RAM 	
							bus_ctrl(4) <= '0'; 						--Activa la máscara 2 de la RAM 	
							bus_ctrl(5) <= '0'; 						--Activa la máscara 3 de la RAM 	
							
							bus_ctrl(6) <= '1';						--Seleccionamos la fila
							bus_ctrl(7) <= '0';						--Seleccionamos la columna
							
							bus_ctrl(8) <= '1';						--Activa el Relój de la RAM
							bus_ctrl(9) <= clk;						--Conmutación de la RAM
							
							bus_ctrl(10) <= '0';						--Escritura activada
							bus_ctrl(11) <= '1';						--Chip enable de la RAM activado
							
							bus_dir(10) <= '1';                 --Activamos el bit de precarga
					
							bus_datos <= AX(7 downto 0);			--Cargamos el bus de datos con la informacion a meter en la RAM
							
							
							
							INST(0) <= LCD_INI("00");						--Bloque de instrucciones para el LCD	
							INST(1) <= LIMPIAR_PANTALLA('1');	
																				------------------------------------------------------
							INST(2) <= CHAR(MM);								--Leyenda: MOV ENT,AL
							INST(3) <= CHAR(MO);								--			  18 (ENT)
							INST(4) <= CHAR(MV);
							CONV_LV_HEX(IX(7 downto 4),aux);
                     INST(5) <= CHAR_ASCII(aux);
							CONV_LV_HEX(IX(3 downto 0),aux);
							INST(6) <= CHAR_ASCII(aux);
							INST(7) <= CHAR_ASCII(x"2C");
							CONV_LV_HEX(AX(7 downto 4),aux);
                     INST(8) <= CHAR_ASCII(aux);
							CONV_LV_HEX(AX(3 downto 0),aux);
							INST(9) <= CHAR_ASCII(aux);
							INST(10) <= POS(2,1);
							
							
							INST(11) <= CHAR_ASCII(x"31");					--Con esta funcion y todas sus llamadas
							INST(12) <= CHAR_ASCII(x"38");					--Convertimos un numero de 4 bits en su código ASCII
							
							INST(13) <= CHAR_ASCII(x"20");					--(CONV_LV_HEX)
							
							CONV_LV_HEX(bus_datos(7 downto 4),aux);
							INST(14) <= CHAR_ASCII(aux);
							CONV_LV_HEX(bus_datos(3 downto 0),aux);
							INST(15) <= CHAR_ASCII(aux);
						
							INST(16) <= CODIGO_FIN(1);
							
							CPrograma <= CPRograma + 1;						--Incremento en el contador de programa
							
					--------------------------------------------------------------------------------------------------------------------------			
					when "10101" =>  								-- 19 MOV IX, AH
																		-- Carga el registro indice con una 
																		-- direccion de memoria y cargamos la parte alta del acumumulador con el dato en 
																		-- dicha direccion
																		
							IX(7 downto 0)<= ent;      		--Cargamos el acumulador con una direccion de memoria
							
							
							
							bus_ctrl(0) <= '0'; 						--Seleccionamos el banco 0 de la SDRAM							
							bus_ctrl(1) <= '0';						--Seleccionamos el banco 1 de la SDRAM		
						
							bus_ctrl(2) <= '0';						--Activa la máscara 0 de la RAM 		
							bus_ctrl(3) <= '0';						--Activa la máscara 1 de la RAM 	
							bus_ctrl(4) <= '0'; 						--Activa la máscara 2 de la RAM 	
							bus_ctrl(5) <= '0'; 						--Activa la máscara 3 de la RAM 	
							
							bus_ctrl(6) <= '1';						--Seleccionamos la fila
							bus_ctrl(7) <= '0';						--Seleccionamos la columna
							
							bus_ctrl(8) <= '1';						--Activa el Relój de la RAM
							bus_ctrl(9) <= clk;						--Conmutación de la RAM
							
							bus_ctrl(10) <= '0';						--Escritura activada
							bus_ctrl(11) <= '1';						--Chip enable de la RAM activado
							
							bus_dir(10) <= '1';                 --Activamos el bit de precarga
					
							bus_datos <= AX(15 downto 8);			--Cargamos el bus de datos con la informacion a meter en la RAM
							
							
							
							
							INST(0) <= LCD_INI("00");						--Bloque de instrucciones para el LCD	
							INST(1) <= LIMPIAR_PANTALLA('1');	
																				------------------------------------------------------
							INST(2) <= CHAR(MM);								--Leyenda: MOV ENT,AH
							INST(3) <= CHAR(MO);								--			  19 (ENT)
							INST(4) <= CHAR(MV);
							INST(5) <= CHAR_ASCII(x"20");
							CONV_LV_HEX(IX(7 downto 4),aux);
                     INST(6) <= CHAR_ASCII(aux);
							CONV_LV_HEX(IX(3 downto 0),aux);
							INST(7) <= CHAR_ASCII(aux);
							INST(8) <= CHAR_ASCII(x"2C");
							CONV_LV_HEX(AX(15 downto 12),aux);
                     INST(9) <= CHAR_ASCII(aux);
							CONV_LV_HEX(AX(11 downto 8),aux);
							INST(10) <= CHAR_ASCII(aux);
							INST(11) <= POS(2,1);
							
							
							INST(12) <= CHAR_ASCII(x"31");					--Con esta funcion y todas sus llamadas
							INST(13) <= CHAR_ASCII(x"39");					--Convertimos un numero de 4 bits en su código ASCII
							
							INST(14) <= CHAR_ASCII(x"20");					--(CONV_LV_HEX)
							
							CONV_LV_HEX(bus_datos(7 downto 4),aux);
							INST(15) <= CHAR_ASCII(aux);
							CONV_LV_HEX(bus_datos(3 downto 0),aux);
							INST(16) <= CHAR_ASCII(aux);
						
							INST(17) <= CODIGO_FIN(1);
							
							CPrograma <= CPRograma + 1;						--Incremento en el contador de programa
							
				--------------------------------------------------------------------------------------------------------------------------	
				when others =>
					AX <= AX;
					CPrograma <= CPrograma;
					IX <= IX;
					
					
					
					
							INST(0) <= LCD_INI("00");						--Bloque de instrucciones para el LCD	
							INST(1) <= LIMPIAR_PANTALLA('1');	
																				------------------------------------------------------
							INST(2) <= CHAR(ME);								--Leyenda: ESPERANDO INSTRUCCION
							INST(3) <= CHAR(S);								
							INST(4) <= CHAR(MP);
							INST(5) <= CHAR(ME);								
							INST(6) <= CHAR(MR);
							INST(7) <= CHAR(MA);								
							INST(8) <= CHAR(MN);
							INST(9) <= CHAR(MD);								
							INST(10) <= CHAR(MO);
							INST(11) <= POS(2,3);
							INST(12) <= CHAR(MI);								
							INST(13) <= CHAR(MN);
							INST(14) <= CHAR(S);								
							INST(15) <= CHAR(MT);
							INST(16) <= CHAR(MR);								
							INST(17) <= CHAR(MU);
							INST(18) <= CHAR(MC);								
							INST(19) <= CHAR(MC);
							INST(20) <= CHAR(MI);								
							INST(21) <= CHAR(MO);
							INST(22) <= CHAR(MN);								
						
							INST(23) <= CODIGO_FIN(1);
				end case;
			  
				CONV_LV_7SEG(CPrograma(7 downto 4), DISP(55 downto 49)); 	--Conversion de contador de programa a display 7 
				CONV_LV_7SEG(CPrograma(3 downto 0), DISP(48 downto 42)); 	--Segmentos
			
				CONV_LV_7SEG(AX(15 downto 12), DISP(41 downto 35)); 	--Conversion de Registro Acumulador a display 7 
				CONV_LV_7SEG(AX(11 downto 8), DISP(34 downto 28)); 	--Segmentos
				CONV_LV_7SEG(AX(7 downto 4), DISP(27 downto 21)); 	
				CONV_LV_7SEG(AX(3 downto 0), DISP(20 downto 14));
				
				dispaux <= "000" & bus_instruccion(4);
				CONV_LV_7SEG(dispaux, DISP(13 downto 7)); 	--Conversion del bus de instruccion a display 7 
				CONV_LV_7SEG(BUS_instruccion(3 downto 0), DISP(6 downto 0)); 				--Segmentos
			end if;
			
		end if;
	end process;

end Practica2;