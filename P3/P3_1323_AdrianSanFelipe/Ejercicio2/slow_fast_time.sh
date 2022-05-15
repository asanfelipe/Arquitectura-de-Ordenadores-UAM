#!/bin/bash

# Inicializamos las variables
P=8
Npaso=64
CachePrimerNivel=1024
CacheNivelSuperior=8388608 #8Mb en binario
TamanioLinea=64
Ninicio=$((2000+512*$P))
Nfinal=$((2000+512*($P+1)))
CacheLectura=cache_lectura.png
CacheEscritura=cache_escritura.png

# Borramos los ficheros .dat de todos los tamaños de la cache
rm -f cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat
# Borramos los ficheros .png de la cache de escritura y lectura
rm -f $CacheLectura $CacheEscritura

# Con touch generamos los ficheros .dat vacíos para la futura recogida de datos
touch cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

echo "Running slow and fast..."

# Con un bucle for ejecutaremos slow y fast con los distintos tamaños de la cache
for ((Tamanio = CachePrimerNivel; Tamanio <= 8192; Tamanio = Tamanio*2)); do
	echo "Tamanio de primer nivel: $Tamanio / Tamanio de nivel superior: $CacheNivelSuperior / Tamanio de linea de ambos niveles: $TamanioLinea"

	for ((N = Ninicio; N <= Nfinal; N += Npaso)); do
		echo "N: $N / $Nfinal..."

		# Ejecutamos slow y recogemos los datos en D1LecturaSlow y D1EscrituraSlow
		valgrind --tool=cachegrind --I1=$Tamanio,1,$TamanioLinea --D1=$Tamanio,1,$TamanioLinea --LL=$CacheNivelSuperior,1,$TamanioLinea --cachegrind-out-file=cachegrindSlow.dat ./slow $N

		D1LecturaSlow=$(cg_annotate cachegrindSlow.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 5) #sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 5

		D1EscrituraSlow=$(cg_annotate cachegrindSlow.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 8) #sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 8


		# Ejecutamos fast y recogemos los datos en D1LecturaFast y D1EscrituraFast
		valgrind --tool=cachegrind --I1=$Tamanio,1,$TamanioLinea --D1=$Tamanio,1,$TamanioLinea --LL=$CacheNivelSuperior,1,$TamanioLinea --cachegrind-out-file=cachegrindFast.dat ./fast $N

		D1LecturaFast=$(cg_annotate cachegrindFast.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 5) #sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 5

		D1EscrituraFast=$(cg_annotate cachegrindFast.dat | head -n 18 | tail -n 1 | sed 's/  */ /g' | cut -d " " -f 8) #sed 's/  */ /g' elimina los * del fichero y cut corta por la columna 8

		# Almacenamos los datos de la ejecución anterior en un fichero de datos cache_tamanio.dat
		echo "$N	$D1LecturaSlow	$D1EscrituraSlow	$D1LecturaFast	$D1EscrituraFast" >> cache_$Tamanio.dat

    # Borramos los ficheros de datos creados en la ejecución de slow y fast ya que ya los hemos utilizado
		rm -f cachegrindSlow.dat cachegrindFast.dat

	done
	sed -i 's/,//g' cache_$Tamanio.dat #sed -i 's/,//g' elimina las comas del fichero cache_tamanio.dat
done

echo "Generando plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Cache Lectura"
set ylabel "Num de fallos"
set xlabel "Tamano de la matriz"
set key right top outside
set grid
set term png
set output "$CacheLectura"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "1024Slow", \
	 "cache_2048.dat" using 1:2 with lines lw 2 title "2048Slow", \
	 "cache_4096.dat" using 1:2 with lines lw 2 title "4096Slow", \
	 "cache_8192.dat" using 1:2 with lines lw 2 title "8192Slow", \
     "cache_1024.dat" using 1:4 with lines lw 2 title "1024Fast", \
     "cache_2048.dat" using 1:4 with lines lw 2 title "2048Fast", \
     "cache_4096.dat" using 1:4 with lines lw 2 title "4096Fast", \
     "cache_8192.dat" using 1:4 with lines lw 2 title "8192Fast"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Cache Escritura"
set ylabel "Num de fallos"
set xlabel "Tamano de la matriz"
set key right top outside
set grid
set term png
set output "$CacheEscritura"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "1024Slow", \
	 "cache_2048.dat" using 1:3 with lines lw 2 title "2048Slow", \
	 "cache_4096.dat" using 1:3 with lines lw 2 title "4096Slow", \
	 "cache_8192.dat" using 1:3 with lines lw 2 title "8192Slow", \
     "cache_1024.dat" using 1:5 with lines lw 2 title "1024Fast", \
     "cache_2048.dat" using 1:5 with lines lw 2 title "2048Fast", \
     "cache_4096.dat" using 1:5 with lines lw 2 title "4096Fast", \
     "cache_8192.dat" using 1:5 with lines lw 2 title "8192Fast"
replot
quit
END_GNUPLOT
