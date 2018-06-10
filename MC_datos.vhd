----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 04/08/2014 
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: La memoria cache está compuesta de 4 bloques de 4 datos con: emplazamiento directo, escritura directa, y la politica convencional en fallo de escritura (fetch on write miss). 
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
use ieee.std_logic_unsigned.all;


entity MC_datos is port (
			CLK : in std_logic;
			reset : in  STD_LOGIC;
			--Interfaz con el MIPS
			ADDR : in std_logic_vector (31 downto 0); --Dir 
			Din : in std_logic_vector (31 downto 0);
			RE : in std_logic;		-- read enable		
			WE : in  STD_LOGIC; 
			ready : out  std_logic;  -- indica si podemos hacer la operación solicitada en el ciclo actual
			Dout : out std_logic_vector (31 downto 0); --dato que se envía al Mips
			--Interfaz con el bus
			MC_Bus_Din : in std_logic_vector (31 downto 0);--para leer datos del bus
			Bus_TRDY : in  STD_LOGIC; --indica que el esclavo (la memoriade datos)  no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			MC_send_addr : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
			MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
			MC_frame : out  STD_LOGIC; --indica que la operación no ha terminado
			MC_Bus_ADDR : out std_logic_vector (31 downto 0); --Dir 
			MC_Bus_data_out : out std_logic_vector (31 downto 0);--para enviar datos por el bus
			MC_bus_RE : out  STD_LOGIC; --RE y WE del bus
			MC_bus_WE : out  STD_LOGIC 
		  );
end MC_datos;

architecture Behavioral of MC_datos is

component UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit : in  STD_LOGIC; --se activa si hay acierto
			dirty_bit : in  STD_LOGIC; --avisa si el bloque a reemplazar es sucio
			bus_TRDY : in  STD_LOGIC; --indica que la memoria no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			match_word : in STD_LOGIC; --indica que la palabra que solicita el procesador es la que se estça leyendo del bus
			MC_RE : out  STD_LOGIC; --RE y WE de la MC
            MC_WE : out  STD_LOGIC;
            bus_RE : out  STD_LOGIC; --RE y WE de la MC
            bus_WE : out  STD_LOGIC;
            MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
            palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)
            mux_origen: out STD_LOGIC; -- Se utiliza para elegir si el origen de la dirección y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
            ready : out  STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habrá que detener el MIPs
            MC_send_addr : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
            MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
            Frame : out  STD_LOGIC; --indica que la operación no ha terminado
			Send_dirty	: out  STD_LOGIC; --indica que hay que enviar el bloque sucio por el bus
			Update_dirty	: out  STD_LOGIC; --indica que hay que actualizar el bit dirty
			Replace_block	: out  STD_LOGIC; -- indica que se ha reemplzado un bloque
			load_addr	: out STD_LOGIC; -- cargar direccion y operación desde mips
			load_data	: out STD_LOGIC; -- cargar dato de entrada desde mips
			mips_origen	: out STD_LOGIC; -- indica si se utilizan los datos procedentes del mips o los guardados
           	mux_out : out STD_LOGIC -- indica qué dato se envía al procesador, el que procede del BUS o el almacenado en la MC
            );
end component;

component reg4 is
    Port (  Din : in  STD_LOGIC_VECTOR (3 downto 0);
            clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
            load : in  STD_LOGIC;
            Dout :out  STD_LOGIC_VECTOR (3 downto 0));
end component;			  

component reg32 is
    Port ( Din : in  STD_LOGIC_VECTOR (31 downto 0);
           clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           load : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- definimos la memoria de contenidos de la cache de datos como un array de 16 palabras de 32 bits
type Ram_MC_data is array(0 to 15) of std_logic_vector(31 downto 0);
signal MC_data : Ram_MC_data := (  		X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", -- posiciones 0,1,2,3,4,5,6,7
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");									
-- definimos la memoria de etiquetas de la cache de datos como un array de 4 palabras de 26 bits
type Ram_MC_Tags is array(0 to 3) of std_logic_vector(25 downto 0);
signal MC_Tags : Ram_MC_Tags := (  		"00000000000000000000000000", "00000000000000000000000000", "00000000000000000000000000", "00000000000000000000000000");												
signal valid_bits_in, valid_bits_out, mask, dirty_bits_in, dirty_bits_out, set_dirty_mask, set_clean_mask: std_logic_vector(3 downto 0); -- se usa para saber si un bloque tiene info válida. Cada bit representa un bloque.									
signal dir_cjto: std_logic_vector(1 downto 0); -- se usa para elegir el cjto al que se accede en la cache de datos. 
signal dir_palabra: std_logic_vector(1 downto 0); -- se usa para elegir la dato solicitada de un determinado bloque. 
signal int_bus_WE, mux_origen, MC_WE, MC_RE, MC_Tags_WE, hit, valid_bit, update_dirty, dirty_bit, replace_block, send_dirty: std_logic;
signal palabra_UC: std_logic_vector(1 downto 0); --se usa al traer un bloque nuevo a la MC (va cambiando de valos para traer todas las palabras)
signal dir_MC: std_logic_vector(3 downto 0); -- se usa para leer/escribir las datos almacenas en al MC. 
signal MC_Din, MC_Dout: std_logic_vector (31 downto 0);
signal MC_Tags_Dout: std_logic_vector(25 downto 0); 
signal mux_out, mips_origen, load_addr, load_data, RE_UC, WE_UC, match_word: std_logic; -- Para anticipación de palabra y buffer de entrada
signal ADDR_UC, Din_UC, ADDR_reg_out, Din_reg_out, MC_Bus_ADDR_UC: std_logic_vector (31 downto 0);
signal RE_reg_in, WE_reg_in, RE_reg_out, WE_reg_out: std_logic_vector (3 downto 0);
begin
 -------------------------------------------------------------------------------------------------- 
 -----MC_data: memoria RAM que almacena los 4 bloques de 4 datos que puede guardar la Cache
 -- dir palabra puede venir de la entrada (cuando se busca un dato solicitado por el Mips) o de la Unidad de control, UC, (cuando se está escribiendo un bloque nuevo 
 -------------------------------------------------------------------------------------------------- 
 dir_palabra <= ADDR_UC(3 downto 2) when (mux_origen='0') else palabra_UC;
 dir_cjto <= ADDR_UC(5 downto 4); -- es emplazamiento directo
 dir_MC <= dir_cjto&dir_palabra; --para direccionar una dato hay que especificar el cjto y la palabra.
 -- la entrada de datos de la MC puede venir del Mips (acceso normal) o del bus (gestión de fallos)
 MC_Din <= Din_UC when (mux_origen='0') else MC_bus_Din;
 memoria_cache_D: process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (MC_WE = '1') then -- sólo se escribe si WE_MC_I vale 1
                MC_data(conv_integer(dir_MC)) <= MC_Din;
            end if;
        end if;
    end process;
    MC_Dout <= MC_data(conv_integer(dir_MC)) when (MC_RE='1') else "00000000000000000000000000000000"; --sólo se lee si RE_MC vale 1
-------------------------------------------------------------------------------------------------- 
-----MC_Tags: memoria RAM que almacena las 4 etiquetas
-------------------------------------------------------------------------------------------------- 
memoria_cache_tags: process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (MC_Tags_WE = '1') then -- sólo se escribe si MC_Tags_WE vale 1
                MC_Tags(conv_integer(dir_cjto)) <= ADDR_UC(31 downto 6);
            end if;
        end if;
    end process;
    MC_Tags_Dout <= MC_Tags(conv_integer(dir_cjto)) when (RE_UC='1' or WE_UC='1') else "00000000000000000000000000"; --sólo se lee si RE_MC vale 1
-------------------------------------------------------------------------------------------------- 
-- registro de validez. Al resetear los bits de validez se ponen a 0 así evitamos falsos positivos por basura en las memorias
-- en el bit de validez se escribe a la vez que en la memoria de etiquetas. Hay que poner a 1 el bit que toque y mantener los demás, para eso usamos una mascara generada por un decodificador
-------------------------------------------------------------------------------------------------- 
mask			<= 	"0001" when dir_cjto="00" else
						"0010" when dir_cjto="01" else
						"0100" when dir_cjto="10" else
						"1000" when dir_cjto="11" else
						"0000";
valid_bits_in <= valid_bits_out OR mask;
bits_validez: reg4 port map(	Din => valid_bits_in, clk => clk, reset => reset, load => MC_tags_WE, Dout => valid_bits_out);
-------------------------------------------------------------------------------------------------- 
valid_bit <= 	valid_bits_out(0) when dir_cjto="00" else
						valid_bits_out(1) when dir_cjto="01" else
						valid_bits_out(2) when dir_cjto="10" else
						valid_bits_out(3) when dir_cjto="11" else
						'0';
-------------------------------------------------------------------------------------------------- 
-- Señal de hit: se activa cuando la etiqueta coincide y el bit de valido es 1
hit <= '1' when ((MC_Tags_Dout= ADDR_UC(31 downto 6)) AND (valid_bit='1'))else '0'; --comparador que compara el tag almacenado en MC con el de la dirección y si es el mismo y el bloque tiene el bit de válido activo devuelve un 1
-------------------------------------------------------------------------------------------------- 
-- registro de bloques sucios. Al resetear los bits de sucio se ponen a 0. Es decir se pierde la información que hay en la MC 
-- Nota debería haber una entrada flush: para vaciar la MC. De forma que todos los bloques sucios se actualizasen en memoria
-------------------------------------------------------------------------------------------------- 
bits_dirty: reg4 port map(	Din => dirty_bits_in, clk => clk, reset => reset, load => Update_dirty, Dout => dirty_bits_out);
set_dirty_mask <= mask OR dirty_bits_out; --Para marcar el cjto actual como sucio
set_clean_mask <= Not(mask) AND dirty_bits_out; --Para marcar el cjto actual como limpio
dirty_bits_in <= set_clean_mask when replace_block ='1' else set_dirty_mask; --cuando se reemplaza el bloque hay que marcar el cjto como limpio. Cuando se escribe hay que marcarlo como sucio
dirty_bit <= 	dirty_bits_out(0) when dir_cjto="00" else
					dirty_bits_out(1) when dir_cjto="01" else
					dirty_bits_out(2) when dir_cjto="10" else
					dirty_bits_out(3) when dir_cjto="11" else
					'0';
-------------------------------------------------------------------------------------------------- 
-----MC_UC: unidad de control
-------------------------------------------------------------------------------------------------- 
Unidad_Control: UC_MC port map (	clk => clk, reset=> reset, RE => RE_UC, WE => WE_UC, hit => hit, bus_TRDY => bus_TRDY, Send_dirty => Send_dirty, Update_dirty => Update_dirty, 
											dirty_bit => dirty_bit, bus_DevSel => bus_DevSel, MC_RE => MC_RE, MC_WE => MC_WE, bus_RE => MC_bus_RE, Replace_block => Replace_block,
											bus_WE => int_bus_WE, MC_tags_WE=> MC_tags_WE, palabra => palabra_UC, mux_origen => mux_origen, 
											ready => ready, MC_send_addr=>MC_send_addr, MC_send_data => MC_send_data, Frame => MC_Frame,
											match_word => match_word, load_addr => load_addr, load_data => load_data, mips_origen => mips_origen, mux_out => mux_out);  
--------------------------------------------------------------------------------------------------
----------- Salidas para el bus
-------------------------------------------------------------------------------------------------- 
MC_bus_WE <= int_bus_WE;

MC_Bus_ADDR_UC <= 	ADDR_UC(31 downto 4)&"0000" when Send_dirty ='0' else 
				MC_Tags_Dout&dir_cjto&"0000"; --Si es fallo mandamos la dirección del bloque que causó el fallo, si es copy-back la del bloque reemplazado
MC_Bus_ADDR <= MC_Bus_ADDR_UC;
					 
MC_Bus_data_out <= MC_Dout; -- se usa para mandar el dato a escribir
--------------------------------------------------------------------------------------------------
----------- Salidas para el Mips
-------------------------------------------------------------------------------------------------- 
Dout <= MC_Dout when (mux_out='0') else MC_bus_Din; -- se usa para mandar el dato al Mips

--------------------------------------------------------------------------------------------------
----------- Almacén entradas desde el Mips
--------------------------------------------------------------------------------------------------
ADDR_UC <= ADDR when (mips_origen='1') else ADDR_reg_out; -- Multiplexores de entrada
Din_UC <= Din when (mips_origen='1') else Din_reg_out;
RE_UC <= RE when (mips_origen='1') else RE_reg_out(0);
WE_UC <= WE when (mips_origen='1') else WE_reg_out(0);

ADDR_reg: reg32 port map (Din => ADDR, clk => clk, reset => reset, load => load_addr, Dout => ADDR_reg_out);
Din_reg: reg32 port map (Din => Din, clk => clk, reset => reset, load => load_data, Dout => Din_reg_out);

RE_reg_in <= "000"&RE;
RE_reg: reg4 port map (	Din => RE_reg_in, clk => clk, reset => reset, load => load_addr, Dout => RE_reg_out);
WE_reg_in <= "000"&WE;
WE_reg: reg4 port map (	Din => WE_reg_in, clk => clk, reset => reset, load => load_addr, Dout => WE_reg_out);

match_word <= '1' when (ADDR_UC=(MC_Bus_ADDR_UC(31 downto 4)&palabra_UC&"00")) else '0'; -- La plabra en el bus corresponde con la pedida por el procesador.

end Behavioral;
