--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2020-2021
--
-- Carlos Miret y Adrián San Felipe
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd
	  Jump	   : out std_logic
   );
end control_unit;

architecture rtl of control_unit is
   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);
   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
   constant OP_ADDI   : t_opCode := "001000";
   constant OP_SLTI   : t_opCode := "001010";
   constant OP_JUMP   : t_opCode := "001000";

begin
--   OPCode <= Instr(31 downto 26);

Branch   <= '1' when opCode = OP_BEQ else '0';

ALUSrc   <= '0' when OPCode= OP_RTYPE or OPCode =OP_BEQ else
			'1';

RegDst   <= '1' when opCode = OP_RTYPE else -- R-type
            '0'; -- lw, sw, beq, j, I-type

RegWrite <= '1' when opCode = OP_LW  else --lw
            '1' when opCode = OP_RTYPE else --rtype
			'1' when OPCode = OP_ADDI else --addi
			'1' when OPCode = OP_SLTI else  --slti
            '1' when OPCode = OP_LUI --lui
			else '0';
			
MemRead  <= '1' when opCode = OP_LW else --lw
            '0';

MemWrite <= '1' when opCode = OP_SW else -- sw
            '0'; 

MemToReg <= '1' when opCode = OP_LW else -- lw
            '0'; -- R-type, sw, beq, j, jal, I-type

ALUOp    <= "000" when opCode = OP_LW  else -- lw
            "000" when opCode = OP_SW  else -- sw
            "110" when opCode = OP_BEQ else -- beq
            "011" when opCode = OP_LUI else --lui
			"000" when opCode = OP_ADDI else
			"010" when opCode = OP_SLTI else
            "010"; -- r-type;

Jump <= '1' when opCode = OP_JUMP else -- j
        '0';
end architecture;
