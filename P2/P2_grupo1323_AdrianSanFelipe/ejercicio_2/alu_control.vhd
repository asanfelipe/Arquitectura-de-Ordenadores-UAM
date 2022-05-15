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
  --modificado al haber error en alucontrol, (pd<-- al final se resolvio y no hizo falta cambio!)
begin
	process(ALUOp, Funct) begin--funct tambien sensible
		case ALUOp is
			when "010" =>
				case Funct is
					when "100010" => ALUControl <= "0001"; -- SUB
					when "100111" => ALUControl <= "0101"; -- NOT
					when "100100" => ALUControl <= "0100"; -- AND
					when "100101" => ALUControl <= "0111"; -- OR
					when "100000" => ALUControl <= "0000"; -- ADD
					when "101010" => ALUControl <= "1010"; -- SLT
					when "100110" => ALUControl <= "0110"; -- XOR
					when others => ALUControl <= "0000";
				end case;
			when "001" => ALUControl <= "0001"; -- BEQ
			when "011" => ALUControl <= "1101"; -- LUI
			when "000" => ALUControl <= "0000"; -- LW, SW
			when others => ALUControl <= "0000";
		end case;
end process;	

end architecture;
