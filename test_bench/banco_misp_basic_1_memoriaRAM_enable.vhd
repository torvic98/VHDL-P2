----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:12:11 04/04/2014 
-- Design Name: 
-- Module Name:    memoriaRAM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- Memoria RAM de 128 palabras de 32 bits
entity RAM_128_32 is port (
		  CLK : in std_logic;
		   enable: in std_logic; --solo se lee o escribe si enable está activado
		  ADDR : in std_logic_vector (31 downto 0); --Dir 
        Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        WE : in std_logic;		-- write enable	
		  RE : in std_logic;		-- read enable		  
		  Dout : out std_logic_vector (31 downto 0));
end RAM_128_32;

architecture Behavioral of RAM_128_32 is
type RamType is array(0 to 127) of std_logic_vector(31 downto 0);
signal RAM : RamType := (  			X"00000010", X"00000000", X"00000000", X"00000000", X"0000F000", X"000F0000", X"00000000", X"00F00000", -- posiciones 0,1,2,3,4,5,6,7
									X"00000001", X"00000010", X"00000000", X"00000100", X"00001000", X"00010000", X"00000000", X"00100000", --posicones 8,9,...
									X"00000002", X"00000020", X"00000000", X"00000200", X"00002000", X"00020000", X"00000000", X"00200000",
									X"00000003", X"00000030", X"00000000", X"00000300", X"00003000", X"00030000", X"00000000", X"00300000",
									X"00000004", X"00000040", X"00000000", X"00000400", X"00004000", X"00040000", X"00000000", X"00400000",
									X"00000005", X"00000050", X"00000000", X"00000500", X"00005000", X"00050000", X"00000000", X"00500000",
									X"00000006", X"00000060", X"00000000", X"00000600", X"00006000", X"00060000", X"00000000", X"00600000",
									X"00000007", X"00000070", X"00000000", X"00000700", X"00007000", X"00070000", X"00000000", X"00700000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

signal dir_7:  std_logic_vector(6 downto 0); 
begin
 
 dir_7 <= ADDR(8 downto 2); -- como la memoria es de 128 plalabras no usamos la dirección completa sino sólo 7 bits. Como se direccionan los bytes, pero damos palabras no usamos los 2 bits menos significativos
 process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (WE = '1') and (enable ='1') then -- sólo se escribe si WE vale 1
                RAM(conv_integer(dir_7)) <= Din;
            end if;
        end if;
    end process;

    Dout <= RAM(conv_integer(dir_7)) when (RE='1') and (enable ='1') else "00000000000000000000000000000000"; --sólo se lee si RE vale 1

end Behavioral;

