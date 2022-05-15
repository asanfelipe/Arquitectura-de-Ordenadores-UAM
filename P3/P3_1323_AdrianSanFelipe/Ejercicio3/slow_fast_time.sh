#!/bin/bash

# Inicializamos las variables
Npaso=32 #Npaso es 32 para el apartado 1 y 16 para el apartado 2 del ejercicio 3
P=8
Ninicio=$((256+256*$P))
Nfinal=$((256+256*($P+1)))
MultDat=mult.dat
CachePNG=mult_cache.png
TimePNG=mult_time.png

# Borramos el fichero .dat y los png
rm -f $MultDat $CachePNG $TimePNG

# Creamos un fichero .dat vacio
touch $MultDat

# Con un bucle for recorremos desde N inicial a N final
for ((N = Ninicio; N <= Nfinal; N += Npaso)); do
	echo "N: $N / $Nfinal..."

	# Ejecutamos matriz y recogemos los datos en D1LecturaMatriz y D1EscrituraMatriz
	TMatriz=$(valgrind --tool=cachegrind --cachegrind-out-file=cachegrindMatriz.dat ./matriz $N | tail -n 1 | cut -d " " -f 3)

	D1LecturaMatriz=$(cg_annotate cachegrindMatriz.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 5) # sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 5

	D1EscrituraMatriz=$(cg_annotate cachegrindMatriz.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 8) # sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 8


	# Ejecutamos matriztrasp y recogemos los datos en D1LecturaMatrizTrasp y D1EscrituraMatrizTrasp
	TMatrizTrasp=$(valgrind --tool=cachegrind --cachegrind-out-file=cachegrindMatrizTrasp.dat ./matriztrasp $N | tail -n 1 | cut -d " " -f 3)

	D1LecturaMatrizTrasp=$(cg_annotate cachegrindMatrizTrasp.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 5) # sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 5

	D1EscrituraMatrizTrasp=$(cg_annotate cachegrindMatrizTrasp.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 8) # sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 8

	# Almacenamos los datos de la ejecución anterior en un fichero de datos mult.dat
	echo "$N	$TMatriz	$D1LecturaMatriz	$D1EscrituraMatriz	$TMatrizTrasp	$D1LecturaMatrizTrasp	$D1EscrituraMatrizTrasp" >> $MultDat

	# Borramos los ficheros de datos creados anteriormente
	rm -f cachegrindMatriz.dat cachegrindMatrizTrasp.dat

done

sed -i 's/,//g' $MultDat #sed -i 's/,//g' elimina las comas del fichero mult.dat

echo "Generando plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Fallos cache"
set ylabel "Numero de fallos"
set xlabel "Tamano matriz"
set key right top outside
set grid
set term png
set output "$CachePNG"
plot "$MultDat" using 1:3 with lines lw 2 title "D1mrNormal", \
	 "$MultDat" using 1:4 with lines lw 2 title "D1mwNormal", \
	 "$MultDat" using 1:6 with lines lw 2 title "D1mrTrasp", \
	 "$MultDat" using 1:7 with lines lw 2 title "D1mwTrasp"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Tiempo de ejecucion"
set ylabel "Tiempo"
set xlabel "Tamano matriz"
set key right top outside
set grid
set term png
set output "$TimePNG"
plot "$MultDat" using 1:2 with lines lw 2 title "Tnormal", \
	 "$MultDat" using 1:5 with lines lw 2 title "Ttrasp"
replot
quit
END_GNUPLOT
