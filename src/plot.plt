#!/usr/bin/gnuplot

set xdata time
set timefmt "%Y-%m-%d"
set format x "%b\n%Y"

set yrange[0:]

set key top left

set terminal pdf
set output "geld.pdf"

set ylabel "Vermögen in Euro"
set xlabel "Datum"

plot "geld.dat" using 1:2 with steps title "Vermögen"
