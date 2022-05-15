--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2020-2021
--
-- Carlos Miret y Adrián San Felipe
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo en flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
      IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is
  --SEÑALES PARA EL PROCESADOR SEGMENTADO
	--VER enables
	signal act_IF_ID	: 	std_logic;
	signal act_ID_EX	: 	std_logic;
	signal act_EX_MEM	:  	std_logic;
	signal act_MEM_WB	:  	std_logic;

	--SEGMENTO IF-------
	signal PCsrc			:  std_logic;
	--Señal entre Mux y PC
	signal MUX32_Pcsrc		:  std_logic_vector (31 downto 0);
	--PC------------
	signal IN_PC 			:  std_logic_vector(31 downto 0);
	signal OUT_PC			:  std_logic_vector(31 downto 0);
	signal MUX32_Jump	:  std_logic_vector (31 downto 0); --?
	signal Jump 	 		:  std_logic;

	--suma de la Alu en segmento IF
	signal PC_Suma4_IF			:  std_logic_vector(31 downto 0);
	signal PC_Suma4_ID			:  std_logic_vector(31 downto 0);
	signal PC_Suma4_EX			:  std_logic_vector(31 downto 0);
	
	-- INSTRUCCION
	signal Instruccion_IF: std_logic_vector(31 downto 0);
	signal Instruccion_ID: std_logic_vector(31 downto 0);
	----------------------------------
	
	
	--SEGMENTO ID-------------------------------------------------
	--RegWrite --Nomenclatura--->Ctrl_RegWrite_EX  ---> ojo, señal provinente de EX
  	signal 	Ctrl_RegWrite_ID 	:  std_logic;
	signal 	Ctrl_RegWrite_EX	:  std_logic;
	signal 	Ctrl_RegWrite_MEM	:  std_logic;
	signal 	Ctrl_RegWrite_WB	:  std_logic;
	--Banco de registros
	signal Registro1_ID: std_logic_vector(31 downto 0);
	signal Registro1_EX: std_logic_vector(31 downto 0);
	signal Registro2_ID: std_logic_vector(31 downto 0);
	signal Registro2_EX: std_logic_vector(31 downto 0);
	signal Registro2_MEM: std_logic_vector(31 downto 0);
	--dato a escribir en banco registros
	signal Wd3_signal: std_logic_vector(31 downto 0);

	signal Instruccion15_0_ID	: std_logic_vector(15 downto 0);
	signal Instruccion15_0_EX	: std_logic_vector(15 downto 0);
	signal Instruccion20_16_ID	: std_logic_vector(4 downto 0);
	signal Instruccion20_16_EX	: std_logic_vector(4 downto 0);
	signal Instruccion15_11_ID	: std_logic_vector(4 downto 0);
	signal Instruccion15_11_EX: std_logic_vector(4 downto 0);
	
	
	
	--Extensores de signo
	signal 	Extension_signo_ID	:  std_logic_vector (15 downto 0);
	signal 	Extension_signo_EX	:  std_logic_vector (15 downto 0);
	---------------------------------------------
	
	
	--SEGMENTO EX--------------------------------------------------------
	--Ctrl del multiplexor de ALUSrc
	signal 	ALUSrc_ID 			:  std_logic;
	signal 	ALUSrc_EX 			:  std_logic;
	
	--Ctrl de ALUOp
	signal 	ALUOp_ID 	 	:  std_logic_vector (2 downto 0);
	signal 	ALUOp_EX  		:  std_logic_vector (2 downto 0);
	
	signal 	ALUControl_ID 	 	:  std_logic_vector (3 downto 0);
	signal 	ALUControl_EX  		:  std_logic_vector (3 downto 0);
	
	--Ctril de RgDest
	signal 	RegDst_EX  			:  std_logic;
	signal 	RegDst_ID  			:  std_logic;
	
	
	signal ALU_Result_EX		:  std_logic_vector (31 downto 0);
	signal ALU_Result_MEM		:  std_logic_vector (31 downto 0);
	signal ALU_Result_WB		:  std_logic_vector (31 downto 0);
	signal ALU_Suma_Result_EX	:  std_logic_vector (31 downto 0);
	signal ALU_Suma_Result_MEM	:  std_logic_vector (31 downto 0);
	
	signal A3_Direccion_Wdata3_EX:	 std_logic_vector(4 downto 0);
	signal A3_Direccion_Wdata3_MEM: std_logic_vector(4 downto 0);
	signal A3_Direccion_Wdata3_WB:  std_logic_vector(4 downto 0);
	
	signal MUX32_entradaALU		:  std_logic_vector (31 downto 0);
	signal InstruccionSignoExtendido_ID	:  std_logic_vector (31 downto 0);
	signal InstruccionSignoExtendido_EX	:  std_logic_vector (31 downto 0);


	signal MUX5Inferior_instr_EX		:  std_logic_vector (4 downto 0);
	signal MUX5Inferior_instr_MEM		:  std_logic_vector (4 downto 0);
	signal MUX5Inferior_instr_WB		:  std_logic_vector (4 downto 0);
	
	------------------------------------
	
	--SEGMENTO MEM
	--Branch en MEM
	signal 	Branch_ID 	 		:  std_logic;	
	signal 	Branch_EX 	 		:  std_logic;
	signal 	Branch_MEM 	 		:  std_logic;
	signal  ZFlag_MEM 			:  std_logic; 
	signal  ZFlag_EX 			:  std_logic; 

	--MemWrite Ctrl_MemWrite_MEM  ---> ojo, señal provinente de MEM
	signal 	Ctrl_MemWrite_ID 	:  std_logic;
	signal 	Ctrl_MemWrite_EX 	:  std_logic;
	signal 	Ctrl_MemWrite_MEM 	:  std_logic;
	
	
	signal DatoSalida_MEM    :   std_logic_vector(31 downto 0);  
	signal DatoSalida_WB    :  std_logic_vector(31 downto 0);  
	
	--MemRead
	signal 	Ctrl_MemRead_ID 	:  std_logic;
	signal 	Ctrl_MemRead_EX 	:  std_logic;
	signal 	Ctrl_MemRead_MEM 	:  std_logic;
	-------------------------------------
	
	--SEGMENTO WB
	signal 	Ctrl_MemToReg_ID 		:  std_logic;
	signal 	Ctrl_MemToReg_EX 		:  std_logic;
	signal 	Ctrl_MemToReg_MEM 		:  std_logic;
	signal 	Ctrl_MemToReg_WB		:  std_logic;
	
	signal MUX32_memoria_salida		:  std_logic_vector (31 downto 0);

	-----------------------------------------------
	--Seniales anteriores
--	--signal Alu_Op2      : std_logic_vector(31 downto 0);
	--signal ALU_Igual    : std_logic;
	--signal AluControl   : std_logic_vector(3 downto 0);
	--signal reg_RD_data  : std_logic_vector(31 downto 0);
	--signal reg_RD       : std_logic_vector(4 downto 0);

	--signal Regs_eq_branch : std_logic;
	--signal PC_next        : std_logic_vector(31 downto 0);
	--signal PC_reg         : std_logic_vector(31 downto 0);
	--signal PC_plus4       : std_logic_vector(31 downto 0);

	--signal Instruction    : std_logic_vector(31 downto 0); -- La instrucción desde lamem de instr
	--signal Inm_ext        : std_logic_vector(31 downto 0); --Lparte baja de la instrucción extendida de signo
	--signal reg_RS, reg_RT : std_logic_vector(31 downto 0);

	--signal dataIn_Mem     : std_logic_vector(31 downto 0); --From Data Memory
	--signal Addr_Branch    : std_logic_vector(31 downto 0);

	--signal Ctrl_Jump, Ctrl_Branch, Ctrl_MemWrite, Ctrl_MemRead,  Ctrl_ALUSrc, Ctrl_RegDest, Ctrl_MemToReg, Ctrl_RegWrite : std_logic;
	--signal Ctrl_ALUOP     : std_logic_vector(2 downto 0);

	--signal Addr_Jump      : std_logic_vector(31 downto 0);
	--signal Addr_Jump_dest : std_logic_vector(31 downto 0);
	--signal desition_Jump     : std_logic;
	--signal Alu_Res        : std_logic_vector(31 downto 0);
  
  
  component alu
    port(
      OpA : in std_logic_vector (31 downto 0);
      OpB : in std_logic_vector (31 downto 0);
      Control : in std_logic_vector (3 downto 0);
      Result : out std_logic_vector (31 downto 0);
      Zflag : out std_logic
    );
  end component;

  component reg_bank
     port (
        Clk   : in std_logic; -- Reloj activo en flanco de subida
        Reset : in std_logic; -- Reset as�ncrono a nivel alto
        A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
        Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
        A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
        Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
        A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
        Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
        We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
     );
  end component reg_bank;

  component control_unit
     port (
        -- Entrada = codigo de operacion en la instruccion:
        OpCode   : in  std_logic_vector (5 downto 0);
        -- Seniales para el PC
        Branch   : out  std_logic; -- 1 = Ejecutandose instruccion branch
		Jump 	 : out std_logic;
        -- Seniales relativas a la memoria
        MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
        MemWrite : out  std_logic; -- Escribir la memoria
        MemRead  : out  std_logic; -- Leer la memoria
        -- Seniales para la ALU
        ALUSrc   : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
        ALUOp    : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
        -- Seniales para el GPR
        RegWrite : out  std_logic; -- 1=Escribir registro
        RegDst   : out  std_logic -- 0=Reg. destino es rt, 1=rd
     );
  end component;

  component alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
 end component alu_control;

begin
	--PC
	PCsrc <= Branch_MEM AND ZFlag_MEM;
	PC_Suma4_IF <= OUT_PC + x"0004";
	IAddr <= OUT_PC;
	IN_PC <= MUX32_Jump;
	MUX32_Pcsrc <= PC_Suma4_IF when PCsrc = '0' else ALU_Suma_Result_MEM;
	MUX32_Jump <= MUX32_Pcsrc when Jump='0' 
					else PC_Suma4_IF(31 downto 28)&Instruccion_ID(25 downto 0)&"00";

	--Entrada de la instruccion
	Instruccion_IF <= IDataIn;
	Instruccion15_0_ID <= Instruccion_ID(15 downto 0);
	Instruccion20_16_ID <= Instruccion_ID(20 downto 16);
	Instruccion15_11_ID <= Instruccion_ID(15 downto 11);
	
	--Alu de arriba etapa EX
	ALU_Suma_Result_EX <=(Extension_signo_EX(13 downto 0)& Instruccion15_0_EX & "00")+PC_Suma4_EX;
	
	--Mapeo del dato a escribir en el banco de registros
	Wd3_signal <= MUX32_memoria_salida;
	A3_Direccion_Wdata3_EX <= MUX5Inferior_instr_EX;
	
	--Multiplexor inferior EX
	MUX5Inferior_instr_EX <= Instruccion20_16_EX when RegDst_EX = '0' else Instruccion15_11_EX;
	
	--Extensor
	Extension_signo_ID <= (others => Instruccion_ID(15));
	
	
	--Multiplexor SEGMENTO WB
	MUX32_memoria_salida <= ALU_Result_WB when Ctrl_MemToReg_WB = '0' else DatoSalida_WB;
	
	--InstruccionSignoExtendido
	InstruccionSignoExtendido_EX	<= Extension_signo_EX&Instruccion15_0_EX;

	
	--Multiplexor ALU EX entrada baja (o rd2 o 15_0 con extension de signo)
	MUX32_entradaALU <= Registro2_EX when ALUSrc_EX = '0' else InstruccionSignoExtendido_EX;
	
	--Memoria
	DatoSalida_MEM <= DDataIn;
	--address de la memoria
	DAddr <= ALU_Result_MEM;
	--habilitacion de lectura
	DRdEn <= Ctrl_MemRead_MEM;
	--habilitacion escritura
	DWrEn <= Ctrl_MemWrite_MEM;
	--dato escrito
	DDataOut <= Registro2_MEM;

	
	--PC_next <= Addr_Jump_dest when desition_Jump = '1' else PC_plus4;
  --Contador del programa
  PC_reg_proc: process(Clk, Reset)
  begin
    if Reset = '1' then
      OUT_PC <= (others => '0');
    elsif rising_edge(Clk) then
      OUT_PC <= IN_PC;
    end if;
  end process;

  --PC_plus4    <= PC_reg + 4;
  --IAddr       <= PC_reg;
  --Instruction <= IDataIn;

  RegsMIPS : reg_bank
  port map (
    Clk   => Clk,
    Reset => Reset,
    A1    => Instruccion_ID(25 downto 21),
    Rd1   => Registro1_ID,
    A2    => Instruccion_ID(20 downto 16),
    Rd2   => Registro2_ID,
    A3    => MUX5Inferior_instr_WB,
    Wd3   => Wd3_signal,
    We3   => Ctrl_RegWrite_WB
  );

  UnidadControl : control_unit
  port map(
    OpCode   => Instruccion_ID(31 downto 26),
    -- Señales para el PC
    Jump   => Jump,
    Branch   => Branch_ID,
    -- Señales para la memoria
    MemToReg => Ctrl_MemToReg_ID,
    MemWrite => Ctrl_MemWrite_ID,
    MemRead  => Ctrl_MemRead_ID,
    -- Señales para la ALU
    ALUSrc   => ALUSrc_ID,
    ALUOP    => ALUOp_ID,
	--ALUControl => ALUControl_ID,
    -- Señales para el GPR
    RegWrite => Ctrl_RegWrite_ID,
    RegDst   => RegDst_ID
  );

  --Inm_ext        <= x"FFFF" & Instruction(15 downto 0) when Instruction(15)='1' else
   --                 x"0000" & Instruction(15 downto 0);
  --Addr_Jump      <= PC_plus4(31 downto 28) & Instruction(25 downto 0) & "00";
  --Addr_Branch    <= PC_plus4 + ( Inm_ext(29 downto 0) & "00");

  --Ctrl_Jump      <= '0'; --nunca salto incondicional

  --Regs_eq_branch <= '1' when (reg_RS = reg_RT) else '0';
  --desition_Jump  <= Ctrl_Jump or (Ctrl_Branch and Regs_eq_branch);
  --Addr_Jump_dest <= Addr_Jump   when Ctrl_Jump='1' else
    --                Addr_Branch when Ctrl_Branch='1' else
    --                (others =>'0');

  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => ALUOp_EX, -- Codigo de control desde la unidad de control
    Funct  => InstruccionSignoExtendido_EX(5 downto 0), -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => ALUControl_EX -- Define operacion a ejecutar por la ALU
  );

  Alu_MIPS : alu
  port map (
    OpA     => Registro1_EX,
    OpB     => MUX32_entradaALU,
    Control => ALUControl_EX,
    Result  => ALU_Result_EX,
    Zflag   => ZFlag_EX
  );

 -- Alu_Op2    <= reg_RT when Ctrl_ALUSrc = '0' else Inm_ext;
  --reg_RD     <= Instruction(20 downto 16) when Ctrl_RegDest = '0' else Instruction(15 downto 11);

  --DAddr      <= Alu_Res;
  --DDataOut   <= reg_RT;
  --DWrEn      <= Ctrl_MemWrite;
  --dRdEn      <= Ctrl_MemRead;
  --dataIn_Mem <= DDataIn;

  --reg_RD_data <= dataIn_Mem when Ctrl_MemToReg = '1' else Alu_Res;
  
	--------------IF - ID--------------------------
  	IF_ID : process (Clk, Reset)
	begin
		if Reset = '1' then
			Instruccion_ID 	<= (others => '0');
			PC_Suma4_ID		<= (others => '0');
			act_IF_ID	    <= '0';
		elsif rising_edge(Clk) then
			-- IF/ID
			Instruccion_ID <= Instruccion_IF;
			PC_Suma4_ID 	<= PC_Suma4_IF;
			act_IF_ID	 <= '1';
		end if;
	end process;
	
	---------ID - EX----------------------------
	ID_EX: process (Clk, Reset,act_IF_ID)
	begin
		if Reset = '1' then
			--reseteo de señales
			act_ID_EX <= '0';
			Ctrl_MemRead_EX <= '0';
			Ctrl_MemToReg_EX <= '0';
			Ctrl_MemWrite_EX <= '0';
			Instruccion15_0_EX <= (others => '0');
			Instruccion15_11_EX <= (others => '0');
			Instruccion20_16_EX <= (others => '0');
			ALUSrc_EX <= '0';
			ALUOp_EX <= (others => '0');
			Ctrl_RegWrite_EX <= '0';
			RegDst_EX <= '0';
			Branch_EX <= '0';
			Extension_signo_EX <= (others => '0');
			PC_Suma4_EX <= (others => '0');
			Registro1_EX <= (others => '0');
			Registro2_EX <= (others => '0');
			
		elsif rising_edge(Clk) then
			-- ID/EX --Mapeo de señales
			act_ID_EX <= '1';
			Ctrl_MemRead_EX <= Ctrl_MemRead_ID;
			Ctrl_MemToReg_EX <= Ctrl_MemToReg_ID;
			Ctrl_MemWrite_EX <= Ctrl_MemWrite_ID;
			Instruccion15_0_EX <= Instruccion15_0_ID;
			Instruccion15_11_EX <= Instruccion15_11_ID;
			Instruccion20_16_EX <= Instruccion20_16_ID;
			ALUSrc_EX <= ALUSrc_ID;
			ALUOp_EX <= ALUOp_ID;
			Ctrl_RegWrite_EX <= Ctrl_RegWrite_ID;
			RegDst_EX <= RegDst_ID;
			Branch_EX <= Branch_ID;
			Extension_signo_EX <= Extension_signo_ID;
			PC_Suma4_EX <= PC_Suma4_ID;
			Registro1_EX <= Registro1_ID;
			Registro2_EX <= Registro2_ID;
		end if;
	end process;
	
	
	EX_MEM: process (Clk, Reset,act_ID_EX)
	begin
		if Reset = '1' then
			act_EX_MEM <= '0';
			ALU_Result_MEM <= (others => '0');
			ALU_Suma_Result_MEM <= (others => '0');
			MUX5Inferior_instr_MEM <= (others => '0');
			Ctrl_MemRead_MEM <= '0';
			Ctrl_MemToReg_MEM<= '0';
			Ctrl_MemWrite_MEM<= '0';
			Ctrl_RegWrite_MEM <= '0';
			Registro2_MEM <= (others => '0');
			--A3_Direccion_Wdata3_MEM <= (others => '0');
			ZFlag_MEM<= '0';
			Branch_MEM <= '0';

		elsif rising_edge(Clk) then
			-- EX/MEM ---Mapeo de señales
			act_EX_MEM <= '1';
			ALU_Result_MEM <= ALU_Result_EX;
			ALU_Suma_Result_MEM <= ALU_Suma_Result_EX;
			MUX5Inferior_instr_MEM <= MUX5Inferior_instr_EX;
			Ctrl_MemRead_MEM <= Ctrl_MemRead_EX;
			Ctrl_MemToReg_MEM<= Ctrl_MemToReg_EX;
			Ctrl_MemWrite_MEM<= Ctrl_MemWrite_EX;
			Ctrl_RegWrite_MEM <= Ctrl_RegWrite_EX;
			Registro2_MEM <= Registro2_EX;
			--A3_Direccion_Wdata3_MEM <= A3_Direccion_Wdata3_EX;
			ZFlag_MEM<= ZFlag_EX;
			Branch_MEM <= Branch_EX;
		end if;
	end process;
	
	MEM_WB: process (Clk, Reset,act_EX_MEM)
	begin
		if Reset = '1' then
			-- MEM/WB
			MUX5Inferior_instr_WB <= (others => '0');
			--A3_Direccion_Wdata3_WB <= (others => '0');
			Ctrl_MemToReg_WB <= '0';
			Ctrl_RegWrite_WB <= '0';
			ALU_Result_WB <= (others => '0');
			DatoSalida_WB <= (others => '0');
		elsif rising_edge(Clk) then
			-- MEM/WB--Mapeo
			MUX5Inferior_instr_WB <= MUX5Inferior_instr_MEM;
			--A3_Direccion_Wdata3_WB <= A3_Direccion_Wdata3_MEM;
			Ctrl_MemToReg_WB <= Ctrl_MemToReg_MEM;
			Ctrl_RegWrite_WB <= Ctrl_RegWrite_MEM;
			ALU_Result_WB <= ALU_Result_MEM;
			DatoSalida_WB <= DatoSalida_MEM;
		end if;
	end process;

end architecture;
