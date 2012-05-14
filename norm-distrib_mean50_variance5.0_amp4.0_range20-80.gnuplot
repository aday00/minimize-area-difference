#!/usr/bin/gnuplot -persist
set title "test title"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean50_variance5.0_amp4.0_range20-80.dat" using 1:2

