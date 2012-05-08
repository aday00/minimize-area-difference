#!/usr/bin/env ruby

#inputs
$expected_dat_file     = "norm-distrib_mean50_variance0.2_amp1.0_range30-70.dat"
$experimental_dat_file = "norm-distrib_mean40_variance0.2_amp1.0_range30-70.dat"
$acceptable_error = 1.0 # acceptable total area difference between both dats

#constants
$dat_filter = /^([-0-9]+)\s+([-_.e0-9]+)$/

def dat_read(filename)
  dat = []
  gc_content = nil
  gc_content_amount = nil
  File.open(filename).readlines.each do |line|
    if ($dat_filter =~ line)
      #puts "#{filename} #{line} #{$1} #{$2}"
      gc_content = $1.to_i
      gc_content_amount = $2.to_f
      dat << [gc_content, gc_content_amount]
    end
  end
  return dat
end
$expected_dat     = dat_read($expected_dat_file)
$experimental_dat = dat_read($experimental_dat_file)

def dat_mean(dat)
  sum = 0.0
  div = 0.0
  dat.each do |gc|
    sum += gc[0] * gc[1]
    div += gc[1]
  end
  return sum/div
end
$expected_mean = dat_mean($expected_dat)
$experimental_mean = dat_mean($experimental_dat)

puts "expected mean:     #{$expected_mean}"
puts "experimental mean: #{$experimental_mean}"

def dat_diff(expected, experimental)
  diffsquares = 0.0
  expected_pt     = nil
  experimental_pt = nil
  0.upto(expected.length - 1) do |i|
    expected_pt     = expected[i][1]
    experimental_pt = experimental[i][1]
    diffsquares += (expected_pt - experimental_pt)**2
  end
  return Math.sqrt(diffsquares)
end
puts "diff: #{dat_diff($expected_dat, $experimental_dat)}"
