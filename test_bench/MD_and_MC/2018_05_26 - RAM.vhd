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
signal RAM : RamType := (  			X"00000000", X"00000004", X"00000008", X"0000000C", X"00000010", X"00000014", X"00000018", X"0000001C", -- posiciones 0,1,2,3,4,5,6,7
									X"00000020", X"00000024", X"00000028", X"0000002C", X"00000030", X"00000034", X"00000038", X"0000003C", --posicones 8,9,...
									X"00000040", X"00000044", X"00000048", X"0000004C", X"00000050", X"00000054", X"00000058", X"0000005C",
									X"00000060", X"00000064", X"00000068", X"0000006C", X"00000070", X"00000074", X"00000078", X"0000007C",
									X"00000080", X"00000084", X"00000088", X"0000008C", X"00000090", X"00000094", X"00000098", X"0000009C",
									X"000000A0", X"000000A4", X"000000A8", X"000000AC", X"000000B0", X"000000B4", X"000000B8", X"000000BC",
									X"000000C0", X"000000C4", X"000000C8", X"000000CC", X"000000D0", X"000000D4", X"000000D8", X"000000DC",
									X"000000E0", X"000000E4", X"000000E8", X"000000EC", X"000000F0", X"000000F4", X"000000F8", X"000000FC",
									X"00000100", X"00000104", X"00000108", X"0000010C", X"00000110", X"00000114", X"00000118", X"0000011C",
									X"00000120", X"00000124", X"00000128", X"0000012C", X"00000130", X"00000134", X"00000138", X"0000013C",
									X"00000140", X"00000144", X"00000148", X"0000014C", X"00000150", X"00000154", X"00000158", X"0000015C",
									X"00000160", X"00000164", X"00000168", X"0000016C", X"00000170", X"00000174", X"00000178", X"0000017C",
									X"00000180", X"00000184", X"00000188", X"0000018C", X"00000190", X"00000194", X"00000198", X"0000019C",
									X"000001A0", X"000001A4", X"000001A8", X"000001AC", X"000001B0", X"000001B4", X"000001B8", X"000001BC",
									X"000001C0", X"000001C4", X"000001C8", X"000001CC", X"000001D0", X"000001D4", X"000001D8", X"000001DC",
									X"000001E0", X"000001E4", X"000001E8", X"000001EC", X"000001F0", X"000001F4", X"000001F8", X"000001FC");

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

