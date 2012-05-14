#!/usr/bin/gnuplot -persist
set title "test title"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean53_variance5.0_amp3.5_range20-80_noise1.5.dat" using 1:2

