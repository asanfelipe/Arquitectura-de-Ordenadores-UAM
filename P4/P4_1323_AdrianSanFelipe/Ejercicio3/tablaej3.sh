#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -pe openmp 16

# inicializar variables
N=1500
fDATAt=tabla_tiempos.dat
fDATAc=tabla_acc.dat

# borrar los fichero DAT
rm -f $fDATAt $fDATAc

# generar los fichero DAT vacíos
touch $fDATAt $fDATAc

for ((hilos = 1; hilos <= 4; hilos += 1)); do
	echo "Hilos usados: $hilos TAM: $N"
	serie=$(./mult_serie $N | grep 'Execution' | awk '{print $3}')
	par1=$(./mult_par1 $N $hilos | grep 'Execution' | awk '{print $3}')
	par2=$(./mult_par2 $N $hilos | grep 'Execution' | awk '{print $3}')
	par3=$(./mult_par3 $N $hilos | grep 'Execution' | awk '{print $3}')

	aceleracion1=$(echo "scale=10; $serie/$par1" | bc -l  | sed 's/^\./0./')
	aceleracion2=$(echo "scale=10; $serie/$par2" | bc -l  | sed 's/^\./0./')
	aceleracion3=$(echo "scale=10; $serie/$par3" | bc -l  | sed 's/^\./0./')

	echo "$hilos"	"$serie"	"$par1" 	"$par2"	"$par3" >> $fDATAt
	echo "$hilos"	"$aceleracion1"	"$aceleracion2" 	"$aceleracion3">> $fDATAc

done
