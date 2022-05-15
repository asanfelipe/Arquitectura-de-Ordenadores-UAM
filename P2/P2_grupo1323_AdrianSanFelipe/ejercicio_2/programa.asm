#--------------------------------------------------------------------------------
#-- Procesador MIPS con pipeline curso Arquitectura 2020-2021
#--
#-- Carlos Miret y Adrián San Felipe
#-- PRACTICA2 EJERCICIO 2
#--------------------------------------------------------------------------------

.data 0
n1: .word 4
n2: .word 5
n3: .word 12
n4: .word 11
n5: .word 16

.text 0
main:
			# Lw n0 (VER DATA) en el registro 9 -> n1 en el registro 10
			lw $t1, 0($zero)  # lw  $r9, 0($r0) -> 4
			lw $t2, 4($zero)  # lw $r10, 4($r0) -> 5
			add $t4, $t1, $t2 # t4 -> 9
			#numero2 en el registro 11
			lw $t3, 8($zero)  # lw $r11, 8($r0) -> 12
			nop
			nop
			nop
			nop
			beq $t4, $t3, jumpsi
			#LA SIGUIENTE INSTRUCCION NO SE TIENE QUE EJECUTAR
			lw $t5, 0($zero)
			lw $t6, 4($zero)
			lw $t7, 16($zero)
			lw $t8, 16($zero)
			nop
			nop
			nop
			
			
jumpsi:	sw $t3, 8($zero)  # memoria3 -> 12
			sw $t2, 8($zero)  # memoria3 -> 5
			#mira a ver que t1 y t2 sean iguales
			beq $t1, $t2, jumpnoef
			lw $t3, 0($zero)  # t3 -> 4
			
jumpno:	beq $t1, $t1, jumpno
			nop 
			nop
			
	

