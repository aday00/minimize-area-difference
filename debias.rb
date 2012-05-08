#!/usr/bin/env ruby

#inputs
$expected_dat_file     = "norm-distrib_mean50_variance0.2_amp1.0_range30-70.dat"
$experimental_dat_file = "norm-distrib_mean40_variance0.2_amp1.0_range30-70.dat"
$acceptable_error = 1.0 # acceptable total area difference between both dats

#constants
$acceptable_error_squared = $acceptable_error**2
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
  diffsquaressum = 0.0

  expected_amt = experimental_amt = nil

  min_gc = [expected[0][0],  experimental[0][0]].min
  max_gc = [expected[-1][0], experimental[-1][0]].max

  expected_idx = experimental_idx = 0

  min_gc.upto(max_gc) do |gc|
    if (expected_idx < expected.length and
         gc == expected[expected_idx][0])
      expected_amt = expected[expected_idx][1]
      expected_idx += 1
    else
      expected_amt = 0
    end

    if (experimental_idx < experimental.length and
        gc == experimental[experimental_idx][0])
      experimental_amt = experimental[experimental_idx][1]
      experimental_idx += 1
    else
      experimental_amt = 0
    end

    diffsquaressum += (expected_amt - experimental_amt)**2
  end
  return diffsquaressum # sum of the squared differences, measures fit, should minimize for best
end
puts "expected:experimental diff, unadjusted: #{dat_diff($expected_dat, $experimental_dat)}"

def dat_shift_to_center(dat, mean)
  shifted = []
  dat.each do |d|
    gc_content_adjusted = (d[0] - mean).to_i
    gc_content_amount   = d[1]
    shifted << [gc_content_adjusted, gc_content_amount]
  end
  return shifted
end
expected_centered     = dat_shift_to_center($expected_dat,     $expected_mean)
experimental_centered = dat_shift_to_center($experimental_dat, $experimental_mean)
centered_diff = dat_diff(expected_centered, experimental_centered)
puts "expected:experimental diff, centered:   #{dat_diff(expected_centered, experimental_centered)}"
