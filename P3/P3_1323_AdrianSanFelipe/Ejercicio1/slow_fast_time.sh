
#!/bin/bash

# inicializar variables
#P = (num_pareja(4 en nuestro caso)+4)=8
P=8
Ninicio=$((10000 + 1024*$P))
#ojo, ha sido modificado para hacer saltos de 64 en 64
Npaso=64
Nfinal=$((10000 + 1024*($P+1)))
fDAT=time_slow_fast.dat
fPNG=time_slow_fast.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q
#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	echo "N: $N / $Nfinal..."

	# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
	# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
	# tercera columna (el valor del tiempo). Dejar los valores en variables
	# para poder imprimirlos en la misma línea del fichero de datos
	slow1=$(./slow $N | grep 'time' | awk '{print $3}')
	slow2=$(./slow $N | grep 'time' | awk '{print $3}')

  slowTime=$(echo "scale=10; ($slow1+$slow2)/2" | bc -l) #bc -l se utiliza para leer solo numeros en vez de variables


	fast1=$(./fast $N | grep 'time' | awk '{print $3}')
	fast2=$(./fast $N | grep 'time' | awk '{print $3}')

	fastTime=$(echo "scale=10; ($fast1+$fast2)/2" | bc -l) #bc -l se utiliza para leer solo numeros en vez de variables
	echo "$N	$slowTime	$fastTime" >> $fDAT
done

echo "Generando plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Tiempo de ejecucion slow.c y fast.c"
set ylabel "Tiempo de ejecucion"
set xlabel "Tamano de la matriz"
set key right top outside
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow.c", \
     "$fDAT" using 1:3 with lines lw 2 title "fast.c"
replot
quit
END_GNUPLOT
