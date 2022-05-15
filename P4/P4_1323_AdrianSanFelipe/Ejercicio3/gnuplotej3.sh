#!/bin/bash

fDATTIMEM=matriz_tiempos.dat
fDATACCM=matriz_aceleracion.dat
fPNGTIMEM=matriz_tiempo.png
fPNGACCM=matriz_aceleracion.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Tiempos de ejecucion Productos matriz"
set ylabel "Tiempo ejecucion (s)"
set xlabel "Tamano matriz"
set key right bottom
set grid
set term png
set output "$fPNGTIMEM"
plot "$fDATTIMEM" using 1:2 with lines lw 2 title "Producto_serie", \
	"$fDATTIMEM" using 1:3 with lines lw 2 title "Producto_paralelo"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Aceleracion Productos matriz"
set ylabel "Aceleracion"
set xlabel "Tamano matriz"
set key right bottom
set grid
set term png
set output "$fPNGACCM"
plot "$fDATACCM" using 1:2 with lines lw 2 title "Aceleracion"
replot
quit
END_GNUPLOT