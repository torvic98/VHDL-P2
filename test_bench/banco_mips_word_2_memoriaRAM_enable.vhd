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
signal RAM : RamType := (  			X"00000010", X"00000000", X"00000000", X"00000000", X"00000000", X"00000001", X"00000002", X"00000003",
									X"00000004", X"00000005", X"00000006", X"00000007", X"00000008", X"00000009", X"0000000A", X"0000000B",
									X"0000000C", X"0000000D", X"0000000E", X"0000000F", X"00000010", X"00000011", X"00000012", X"00000013", 
									X"00000014", X"00000015", X"00000016", X"00000017", X"00000018", X"00000019", X"0000001A", X"0000001B",
									X"0000001C", X"0000001D", X"0000001E", X"0000001F", X"00000020", X"00000021", X"00000022", X"00000023",
									X"00000024", X"00000025", X"00000026", X"00000027", X"00000028", X"00000029", X"0000002A", X"0000002B",
									X"0000002C", X"0000002D", X"0000002E", X"0000002F", X"00000030", X"00000031", X"00000032", X"00000033",
									X"00000034", X"00000035", X"00000036", X"00000037", X"00000038", X"00000039", X"0000003A", X"0000003B",
									X"0000003C", X"0000003D", X"0000003E", X"0000003F", X"00000040", X"00000041", X"00000042", X"00000043",
									X"00000044", X"00000045", X"00000046", X"00000047", X"00000048", X"00000049", X"0000004A", X"0000004B",
									X"0000004C", X"0000004D", X"0000004E", X"0000004F", X"00000050", X"00000051", X"00000052", X"00000053",
									X"00000054", X"00000055", X"00000056", X"00000057", X"00000058", X"00000059", X"0000005A", X"0000005B",
									X"0000005C", X"0000005D", X"0000005E", X"0000005F", X"00000060", X"00000061", X"00000062", X"00000063",
									X"00000064", X"00000065", X"00000066", X"00000067", X"00000068", X"00000069", X"0000006A", X"0000006B",
									X"0000006C", X"0000006D", X"0000006E", X"0000006F", X"00000070", X"00000071", X"00000072", X"00000073",
									X"00000074", X"00000075", X"00000076", X"00000077", X"00000078", X"00000079", X"0000007A", X"0000007B");

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

