#!/usr/bin/gnuplot -persist
set title "test title"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean40_variance0.2_amp0.8_range30-70_noise0.1.dat" using 1:2

