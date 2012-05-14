#!/usr/bin/gnuplot -persist
set title "test title"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean50_variance0.5_amp1.0_range30-70.dat" using 1:2

