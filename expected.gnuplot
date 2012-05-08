#!/usr/bin/gnuplot -persist
set title "test title"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "expected.dat" using 1:2

