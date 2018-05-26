library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--Mux 4 a 1
entity UD is
    Port ( 	Reg_Rs_ID: in  STD_LOGIC_VECTOR (4 downto 0); --registros Rs y Rt en la etapa ID
		   Reg_Rt_ID	: in  STD_LOGIC_VECTOR (4 downto 0);
			MemRead_EX	: in std_logic; -- información sobre la instrucción en EX (destino, si lee de memoria y si escribe en registro)
			RegWrite_EX	: in std_logic;
			RW_EX			: in  STD_LOGIC_VECTOR (4 downto 0);
			RegWrite_Mem	: in std_logic;-- informacion sobre la instruccion en Mem (destino y si escribe en registro)
			RW_Mem			: in  STD_LOGIC_VECTOR (4 downto 0);
			IR_op_code	: in  STD_LOGIC_VECTOR (5 downto 0); -- código de operación de la instrucción en IEEE
            PCSrc			: in std_logic; -- 1 cuando se produce un salto 0 en caso contrario
			FP_add_EX	: in std_logic; -- Indica si la instrucción en EX es un ADDFP
			FP_done		: in std_logic; -- Informa cuando la operación de suma en FP ha terminado
			Kill_IF		: out  STD_LOGIC; -- Indica que la instrucción en IF no debe ejecutarse (fallo en la predicción de salto tomado)
			Parar_ID		: out  STD_LOGIC; -- Indica que las etapas ID y previas deben parar
			Parar_EX		: out  STD_LOGIC); -- Indica que las etapas EX y previas deben parar
end UD;
Architecture Behavioral of UD is
	signal Parar_ID_BEQ, Parar_ID_UA, Parar_EX_ADDFP : std_logic;
begin
	-- AHora mismo no hace nada. Hay que diseñar la lógica que genera estas señales.
	-- Además hay que conectar estas señales con los elementos adecuados para que las órdenes que indican se realicen
	Parar_ID_BEQ <= '1' when (IR_op_code="000100" and ( (Reg_Rs_ID=RW_EX and RegWrite_EX='1') or (Reg_Rt_ID=RW_EX and RegWrite_EX='1')
	                       or (Reg_Rs_ID=RW_MEM and RegWrite_MEM='1') or (Reg_Rt_ID=RW_MEM and RegWrite_MEM='1') ) )
				else '0';
	Parar_ID_UA <= '1' when (MemRead_EX='1' and (RW_EX=Reg_Rs_ID or (RW_EX=Reg_Rt_ID and not IR_op_code="000010"))) else '0';
	Parar_EX_ADDFP <= '1' when (FP_add_EX='1' and FP_done='0') else '0';
	Kill_IF <= PCSrc and not (Parar_ID_BEQ or Parar_ID_UA or Parar_EX_ADDFP);
	Parar_ID <= Parar_ID_BEQ or Parar_ID_UA;
	Parar_EX <= Parar_EX_ADDFP;
end Behavioral;
