#!/usr/bin/gnuplot -persist
set title "Fit GC content: expected_gc_content[i] =~ experimental_gc_content[i + (10.2)] * (1.1861520967116)"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean50_variance0.5_amp1.0_range30-70.dat" using 1:2 with lines, \
     "norm-distrib_mean40_variance0.5_amp0.8_range30-70_noise0.5.dat" using 1:2 with lines, \
     "norm-distrib_mean40_variance0.5_amp0.8_range30-70_noise0.5_fit00.dat" using 1:2 with lines

