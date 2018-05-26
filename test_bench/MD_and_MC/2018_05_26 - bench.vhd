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

		-- 01: miss + read + clear ON 0 (0x144)
		RE <= '1';
		Addr <= conv_std_logic_vector(324, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);

		-- 02: miss + read + clear ON 1 (0x090)
		RE <= '1';
		Addr <= conv_std_logic_vector(144, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 03: hit + write ON 1 (0x098)
		Addr <= conv_std_logic_vector(152, 32);
		Din <= X"00003098";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 04: miss + read + dirty ON 1 (0x01C)
		RE <= '1';
		Addr <= conv_std_logic_vector(28, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 05: hit + read ON 1 (0x010)
		RE <= '1';
		Addr <= conv_std_logic_vector(16, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 06: miss + write + clean ON 2 (0x1E4) 
		Addr <= conv_std_logic_vector(484, 32);
		Din <= X"000061E4";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 07: miss + read + dirty ON 2 (0x0E4)
		RE <= '1';
		Addr <= conv_std_logic_vector(228, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 08: hit + read ON 0 (0x14C)
		RE <= '1';
		Addr <= conv_std_logic_vector(332, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 09: hit + write ON 0 (0x14C)
		Addr <= conv_std_logic_vector(332, 32);
		Din <= X"0000914C";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 10: hit + read ON 2 (0x0E8)
		RE <= '1';
		Addr <= conv_std_logic_vector(232, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';


		-- 11: miss + read + clear 3 (0x130)
		RE <= '1';
		Addr <= conv_std_logic_vector(304, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 12: miss + write + clear 3 (0x03C)
		Addr <= conv_std_logic_vector(60, 32);
		Din <= X"0001203C";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 13: miss + write + dirty ON 0 (0x084)
		Addr <= conv_std_logic_vector(132, 32);
		Din <= X"00013084";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 14: miss + read + dirty ON 0 (0x1C0)
		RE <= '1';
		Addr <= conv_std_logic_vector(448, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 15: miss + read + dirty ON 3 (0x1F0)
		RE <= '1';
		Addr <= conv_std_logic_vector(496, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 16: miss + write + clear 0 (0x0C0)
		Addr <= conv_std_logic_vector(192, 32);
		Din <= X"000160C0";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 17: miss + write + clear 1 (0x154)
		Addr <= conv_std_logic_vector(340, 32);
		Din <= X"00017154";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 18: hit + read ON 3  (0x1F8)
		RE <= '1';
		Addr <= conv_std_logic_vector(504, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 19: hit + write ON 3  (0x1F4)
		Addr <= conv_std_logic_vector(500, 32);
		Din <= X"000191F4";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 20: miss + read + clear 2 (0x16C)
		RE <= '1';
		Addr <= conv_std_logic_vector(364, 32);
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1';
		end if;
		wait until rising_edge(clk);
		RE <= '0';

		-- 21: hit + write ON 2  (0x160)
		Addr <= conv_std_logic_vector(352, 32);
		Din <= X"00021160";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 22: miss + write + dirty ON 2 (0x12C)
		Addr <= conv_std_logic_vector(300, 32);
		Din <= X"0002212C";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 23: miss + write + dirty ON 1 (0x110)
		Addr <= conv_std_logic_vector(272, 32);
		Din <= X"00023110";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';

		-- 24: miss + write + dirty ON 3 (0x130)
		Addr <= conv_std_logic_vector(304, 32);
		Din <= X"00024130";
		WE <= '1';
		wait for 1 ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
		end if;
		wait until rising_edge(clk);
		WE <= '0';
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
