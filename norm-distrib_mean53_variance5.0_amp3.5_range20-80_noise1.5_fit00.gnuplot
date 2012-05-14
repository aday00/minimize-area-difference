#!/usr/bin/gnuplot -persist
set title "Fit GC content: expected_gc_content[i] =~ experimental_gc_content[i + (-2.7)] * (1.07333333333333)"
set xlabel "GC content fraction"
set ylabel "GC content at fraction in window"
plot "norm-distrib_mean50_variance5.0_amp4.0_range20-80.dat" using 1:2 with lines, \
     "norm-distrib_mean53_variance5.0_amp3.5_range20-80_noise1.5.dat" using 1:2 with lines, \
     "norm-distrib_mean53_variance5.0_amp3.5_range20-80_noise1.5_fit00.dat" using 1:2 with lines

