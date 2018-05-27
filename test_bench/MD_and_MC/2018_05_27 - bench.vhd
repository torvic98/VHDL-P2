-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY testbench_MD_mas_MC IS
END testbench_MD_mas_MC;

ARCHITECTURE behavior OF testbench_MD_mas_MC IS 

	-- Component Declaration
	COMPONENT MD_mas_MC is port (
		CLK : in std_logic;
		reset: in std_logic; -- sólo resetea el controlador de DMA
		ADDR : in std_logic_vector (31 downto 0); --Dir 
		Din : in std_logic_vector (31 downto 0);--entrada de datos desde el Mips
		WE : in std_logic;		-- write enable	del MIPS
		RE : in std_logic;		-- read enable del MIPS	
		Mem_ready: out std_logic; -- indica si podemos hacer la operación solicitada en el ciclo actual
		Dout : out std_logic_vector (31 downto 0)); --salida que puede leer el MIPS
	end COMPONENT;

	SIGNAL clk, reset, RE, WE, Mem_ready :  std_logic;
	signal ADDR, Din, Dout : std_logic_vector (31 downto 0);

	-- Clock period definitions
	constant CLK_period : time := 10 ns;
BEGIN

	-- Component Instantiation
	uut: MD_mas_MC PORT MAP(clk=> clk, reset => reset, ADDR => ADDR, Din => Din, RE => RE, WE => WE, Mem_ready => Mem_ready, Dout => Dout);

	-- Clock process definitions
	CLK_process :process
	begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
	end process;

	stim_proc: process
	begin		

		-- INICIO periodo de RESET
		reset <= '1';
		addr <= conv_std_logic_vector(0, 32);
		RE <= '0';
		WE <= '0';
		wait for 20 ns;	
		reset <= '0';
		-- FIN periodo de RESET

		-- INICIO peticiones a MC

		-- 01: miss + write + clear ON 1 (0x154)
		WE <= '1';
		Addr <= conv_std_logic_vector(344, 32);
		Din <= X"00001234";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 02: miss + read + clear ON 2 (0x06C)
		RE <= '1';
		Addr <= conv_std_logic_vector(108, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 03: miss + read + clear ON 0 (0x140)
		Addr <= conv_std_logic_vector(320, 32);
		RE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 04: hit + read ON 2 (0x064)
		RE <= '1';
		Addr <= conv_std_logic_vector(100, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 05: hit + write ON 2 (0x060)
		WE <= '1';
		Addr <= conv_std_logic_vector(96, 32);
		Din <= X"00001111";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 06: write + read + clean ON 0 (0x180)
		WE <= '1';
		Din <= X"00002222";
		Addr <= conv_std_logic_vector(384, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 07: miss + write + dirty ON 0 (0x1C0)
		WE <= '1';
		Addr <= conv_std_logic_vector(448, 32);
		Din <= X"00003333";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 08: miss + read + dirty ON 1 (0x01C)
		RE <= '1';
		Addr <= conv_std_logic_vector(28, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 09: miss + read + clean ON 1 (0x09C)
		RE <= '1';
		Addr <= conv_std_logic_vector(156, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 10: hit + write ON 2 (0x06C)
		WE <= '1';
		Addr <= conv_std_logic_vector(108, 32);
		Din <= X"00004444";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';


		-- 11: miss + read + clear 3 (0x1FC)
		RE <= '1';
		Addr <= conv_std_logic_vector(508, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 12: hit + read on 3 (0x1F0)
		RE <= '1';
		Addr <= conv_std_logic_vector(496, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 13: miss + read + dirty ON 0 (0x0C4)
		RE <= '1';
		Addr <= conv_std_logic_vector(196, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 14: miss + write + dirty ON 2 (0x0E8)
		WE <= '1';
		Addr <= conv_std_logic_vector(232, 32);
		Din <= X"00005555";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 15: miss + write + clear ON 0 (0x044)
		WE <= '1';
		Addr <= conv_std_logic_vector(68, 32);
		Din <= X"00006666";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 16: miss + write + dirty ON 0 (0x088)
		WE <= '1';
		Addr <= conv_std_logic_vector(136, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 17: miss + read + dirty ON 0 (0x0C0)
		RE <= '1';
		Addr <= conv_std_logic_vector(192, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';
		
		-- 18: miss + read + dirty ON 2 (0x164)
		RE <= '1';
		Addr <= conv_std_logic_vector(356, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';
		
		-- 19: hit + read ON 1 (0x094)
		RE <= '1';
		Addr <= conv_std_logic_vector(148, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';
		
		-- 20: hit + write ON 3 (0x1F8)
		WE <= '1';
		Addr <= conv_std_logic_vector(504, 32);
		Din <= X"00000101";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 21: hit + write ON 3 (0x1F4)
		WE <= '1';
		Addr <= conv_std_logic_vector(500, 32);
		Din <= X"00000047";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 22: miss + write + clear ON 2 (0x120)
		WE <= '1';
		Addr <= conv_std_logic_vector(288, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 23: miss + write + clear ON 2 (0x028)
		WE <= '1';
		Addr <= conv_std_logic_vector(40, 32);
		Din <= X"00000200";
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		WE <= '0';
		
		-- 24: hit + read ON 0 (0x0CC)
		RE <= '1';
		Addr <= conv_std_logic_vector(204, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		RE <= '0';
		
		
		-- FIN peticiones a MC

		-- INICIO Flush de memoria caché
		RE <= '1';
		Addr <= conv_std_logic_vector(0, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		RE <= '1';
		Addr <= conv_std_logic_vector(16, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		RE <= '1';
		Addr <= conv_std_logic_vector(32, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		RE <= '1';
		Addr <= conv_std_logic_vector(48, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';
		-- FIN Flush de memoria caché

		wait;

	end process;

END;
