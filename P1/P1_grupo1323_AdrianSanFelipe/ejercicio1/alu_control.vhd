--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2019-2020.
--
-- Carlos Miret y Adrián San Felipe
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
end alu_control;

architecture rtl of alu_control is
  -- Tipo para los codigos de control de la ALU:
  subtype t_aluControl is std_logic_vector (3 downto 0);
  -- Codigos de control:
  constant ALU_OR   : t_aluControl := "0111";
  constant ALU_NOP  : t_aluControl := "0101";
  constant ALU_XOR  : t_aluControl := "0110";
  constant ALU_AND  : t_aluControl := "0100";
  constant ALU_SUB  : t_aluControl := "0001";
  constant ALU_ADD  : t_aluControl := "0000";
  constant ALU_SLT  : t_aluControl := "1010";
  constant ALU_S16  : t_aluControl := "1101";
  --codigo añiadido
  constant ALU_BEQ  : t_aluControl := "0001";
  constant ALU_SLTI  : t_aluControl := "1010";


  begin
  AluControl <= ALU_ADD when ALUOp = "000" else -- lw o sw, addi
                ALU_S16 when ALUOp = "011" else -- lui,
				--INSTRUCCION AÑADIDA
		ALU_BEQ WHEN ALUOp = "110" else    --beq
		ALU_SLTI WHEN ALUOp = "111" else   --slti
				----------------------------
                ALU_ADD when ALUOp = "010" and Funct = "100000" else -- add
                ALU_SUB when ALUOp = "010" and Funct = "100010" else -- sub
                ALU_AND when ALUOp = "010" and Funct = "100100" else -- and
                ALU_OR  when ALUOp = "010" and Funct = "100101" else -- or
		ALU_XOR when ALUOp = "010" and Funct = "100110" else -- xor
                ALU_SLT when ALUOp = "010" and Funct = "101010" else -- slt
                ALU_NOP;-- when AluOp_IDEX = "10" and Inm_ext_IDEX(5 downto 0) = "100110"; -- xor

end architecture;
