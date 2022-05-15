#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -pe openmp 16

# inicializar variables
P=8
Ninicio=$((512+$P))
Nfinal=$((1024+512+$P))
Npaso=64

fDATTIMEM=matriz_tiempos.dat
fDATACCM=matriz_aceleracion.dat
fPNGTIMEM=matriz_tiempo.png
fPNGACCM=matriz_aceleracion.png

# borrar los fichero DAT y los fichero PNG
rm -f $fDATTIMEM $fDATACCM $fPNGTIMEM $fPNGACCM

# generar los fichero DAT vacíos
touch $fDATTIMEM $fDATACCM

# bucle para TAM desde Ninicio hasta Nfinal
for ((TAM = Ninicio; TAM <= Nfinal; TAM += Npaso)); do
	echo "TAM: $TAM / $Nfinal..."
	serie=0
	par3=0
	aceleracion=0

	serie=$(./mult_serie $TAM | grep 'Execution' | awk '{print $3}')
	par3=$(./mult_par3 $TAM 4 | grep 'Execution' | awk '{print $3}')

	aceleracion=$(echo "scale=10; $serie/$par3" | bc -l  | sed 's/^\./0./')

	echo "$TAM"	"$serie"	"$par3" >> $fDATTIMEM
	echo "$TAM"	"$aceleracion" >> $fDATACCM

done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Tiempos de ejecucion multiplicacion matriz"
set ylabel "Tiempo ejecucion (s)"
set xlabel "Tamano matriz"
set key right top outside
set grid
set term png
set output "$fPNGTIMEM"
plot "$fDATTIMEM" using 1:2 with lines lw 2 lc rgb 'blue' title "Serie" , \
	"$fDATTIMEM" using 1:3 with lines lw 2 lc rgb 'red' title "Paralelo"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Aceleracion multiplicacion matriz"
set ylabel "Aceleracion"
set xlabel "Tamano matriz"
set key right top outside
set grid
set term png
set output "$fPNGACCM"
plot "$fDATACCM" using 1:2 with lines lw 2 lc rgb 'red' title "Aceleracion"
replot
quit
END_GNUPLOT
