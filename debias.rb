#!/usr/bin/env ruby

#inputs
#$expected_dat_file     = "norm-distrib_mean50_variance0.2_amp1.0_range30-70.dat"
#$expected_dat_file     = "norm-distrib_mean50_variance0.5_amp1.0_range30-70.dat"
$expected_dat_file     = "norm-distrib_mean50_variance5.0_amp4.0_range20-80.dat"
#$experimental_dat_file = "norm-distrib_mean40_variance0.2_amp0.8_range30-70.dat"
#$experimental_dat_file = "norm-distrib_mean40_variance0.2_amp0.8_range30-70_noise0.1.dat"
#$experimental_dat_file = "norm-distrib_mean40_variance0.5_amp0.8_range30-70_noise0.5.dat"
$experimental_dat_file = "norm-distrib_mean53_variance5.0_amp3.5_range20-80_noise1.5.dat"
$acceptable_error = 1.0 # acceptable total area difference between both dats

#constants
$acceptable_error_squared = $acceptable_error**2
$dat_filter = /^([-0-9]+)\s+([-_.e0-9]+)$/
#$finesteps = 100 # when fine-tuning expected-to-experimental fit, use this many steps
$finesteps = 10 # when fine-tuning expected-to-experimental fit, use this many steps
$halffine = $finesteps / 2.0
$fineamps = 300 # when fine-tuning amplification, use this many steps
$amprange = 2 # fine-tune amplification at least $amprange*guess plus-or-minus from the experimental to settle on best amplification

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

def dat_interpolate(dat)
  # multiple the number of data points in dat by linear interpolation between each point
  # this allows for finer-grained dat_shift offsets to fit experimental into expected
  interpolated = []
  gc_content_prev = 0
  gc_content_amount_prev = 0
  dat.each do |d|
    gc_content = d[0]
    gc_content_fine = (gc_content * $finesteps) - $finesteps # interpolating up from gc_content_prev, which is $finesteps prior
    gc_content_amount = d[1].to_f
    gc_content_amount_diff  = gc_content_amount - gc_content_amount_prev
    #puts "interpolating for #{gc_content} #{gc_content_amount}"
    0.upto($finesteps - 1) do |step|
      gc_content_interp = gc_content_fine + step
      #gc_content_amount_weight = 1 - ($finesteps - step).to_f/$finesteps
      gc_content_amount_weight = step.to_f/$finesteps
      gc_content_amount_interp = gc_content_amount_weight*gc_content_amount_diff + gc_content_amount_prev
      #puts "  interp'd #{gc_content_interp} #{gc_content_amount_interp} with weight #{gc_content_amount_weight} on diff #{gc_content_amount_diff} plus prev #{gc_content_amount_prev}"
      interpolated << [gc_content_interp, gc_content_amount_interp]
    end
    gc_content_prev = gc_content
    gc_content_amount_prev = gc_content_amount
  end
  return interpolated
end
$expected_dat_interp = dat_interpolate($expected_dat)
$experimental_dat_interp = dat_interpolate($experimental_dat)

def dat_diff(expected, experimental)
  diffsquaressum = 0.0

  expected_amt = experimental_amt = nil

  #min_gc = ([expected[0][0],  experimental[0][0]].min * $halffine).round
  #max_gc = ([expected[-1][0], experimental[-1][0]].max * $halffine).round
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

def dat_shift(dat, shift)
  shifted = []
  #interpolate = (shift.to_i != shift) # if using a non-integer shift, will need to interpolate values between two expected values.  if using integer shift, then shifted gc_contents should stay as integers
  dat.each do |d|
    gc_content_adjusted = (d[0] + shift)
    #gc_content_adjusted = gc_content_adjusted.to_i if (!interpolate and gc_content_adjusted.to_i == gc_content_adjusted) # keep as int
    gc_content_amount   = d[1]
    shifted << [gc_content_adjusted, gc_content_amount]
  end
  return shifted
end
expected_centered     = dat_shift($expected_dat,     -$expected_mean.to_i) # XXX: actually shift the interpolated dat
experimental_centered = dat_shift($experimental_dat, -$experimental_mean.to_i) #XXX
centered_diff = dat_diff(expected_centered, experimental_centered)
puts "expected:experimental diff, centered:   #{dat_diff(expected_centered, experimental_centered)}"
puts "expected_gc_content[i] =~ experimental_gc_content[i + (#{$expected_mean - $experimental_mean})]"

offset_diff = ($expected_mean - $experimental_mean).abs.ceil
offsets = [$expected_mean, $experimental_mean]
$best_offset = nil
$best_diff = 2**32
lo = offsets.min.floor - offset_diff - $experimental_mean.ceil  # reasonable lower bound that the best_offset could be
hi = offsets.max.ceil  + offset_diff - $experimental_mean.floor # reasonable upper bound yadda yadda
#lo = -100
#hi = 100
experimental_shifted = nil
(lo*$finesteps).upto(hi*$finesteps) do |offset|
  exper = dat_shift($experimental_dat_interp, offset)
  diff = dat_diff($expected_dat_interp, exper)
  #puts "diff at #{offset} is #{diff}"
  if (diff < $best_diff)
    $best_offset = offset
    $best_diff   = diff
    experimental_shifted = exper
    #puts "best diff at #{offset} is #{diff}"
  end
end

puts "expected:experimental diff, found:      #{$best_diff}"
puts "expected_gc_content[i] =~ experimental_gc_content[i + (#{$best_offset/$finesteps.to_f})]"

def dat_max(dat)
  gc_content_amt_max = -(2**32)
  dat.each do |d|
    gc_content_amount   = d[1]
    if (gc_content_amount > gc_content_amt_max)
      gc_content_amt_max = gc_content_amount
    end
  end
  return gc_content_amt_max
end
$expected_max     = dat_max($expected_dat)
$experimental_max = dat_max($experimental_dat)
puts "expected     max: #{$expected_max}"
puts "experimental max: #{$experimental_max}"
$amplification = $expected_max/$experimental_max
puts "expected:experimental amplification: #{$amplification}"

def dat_amplify(dat, amplification)
  amplified = []
  dat.each do |d|
    gc_content                 = d[0]
    gc_content_amount_adjusted = (d[1] * amplification)
    amplified << [gc_content, gc_content_amount_adjusted]
  end
  return amplified
end
experimental_amped = dat_amplify(experimental_shifted, $amplification)
experimental_amped_diff = dat_diff($expected_dat_interp, experimental_amped)

if (false) # debug
  puts "exper orig:"
  $experimental_dat.each do |d|
    #printf("%i\t%f\n", d[0], d[1])
    puts "#{d[0]}\t#{d[1]}"
  end
  puts "exper:"
  $experimental_dat_interp.each do |d|
    #printf("%i\t%f\n", d[0], d[1])
    puts "#{d[0]}\t#{d[1]}"
  end
  puts "shifted:"
  experimental_shifted.each do |d|
    #printf("%i\t%f\n", d[0], d[1])
    puts "#{d[0]}\t#{d[1]}"
  end
  puts "amped:"
  experimental_amped.each do |d|
    #printf("%i\t%f\n", d[0], d[1])
    puts "#{d[0]}\t#{d[1]}"
  end
end

puts "expected:experimental diff, amplified:  #{experimental_amped_diff}"
puts "expected_gc_content[i] =~ experimental_gc_content[i + (#{$best_offset.to_f / $finesteps})] * (#{$amplification})"

hi = $amplification*$amprange
lo = $amplification - (hi - $amplification)
hi = ($fineamps*hi).ceil
lo = ($fineamps*lo).floor
best_amp = nil
best_amp_diff = 2**32
experimental_itr_amped = nil
lo.upto(hi) do |a|
  amp = a.to_f / $fineamps
  amped = dat_amplify(experimental_shifted, amp)
  diff = dat_diff($expected_dat_interp, amped)
  #puts "diff at #{amp} is #{experimental_amped_diff}"
  if (diff < best_amp_diff)
    best_amp = amp
    best_amp_diff = diff
    experimental_itr_amped = amped
    #puts "best diff at #{amp} is #{experimental_amped_diff}"
  end
end
puts "expected:experimental diff, iteratively amplified:  #{best_amp_diff}"
puts "expected_gc_content[i] =~ experimental_gc_content[i + (#{$best_offset.to_f / $finesteps})] * (#{best_amp})"

#puts "debiased data follows according to above linear transformation:"
#experimental_amped.each do |d|
#  puts "#{d[0]}\t#{d[1]}"
#end

#puts "said data in original bins:"
puts "debiased data follows according to above linear transformation:"
idx = 0
$experimental_dat.each do |ed|
  gc_content = ed[0]
  #puts "egcc #{gc_content}"
  #while (idx < experimental_amped.length)
  while (idx < experimental_itr_amped.length)
    #puts "?gcc #{experimental_amped[idx][0]} #{$finesteps}"
    i = idx
    idx += 1
    if (experimental_itr_amped[i][0] % $finesteps == 0)
      #printf("%i\t%f\n", experimental_amped[i][0] / $finesteps, experimental_amped[i][1])
      puts "#{experimental_itr_amped[i][0] / $finesteps}\t#{experimental_itr_amped[i][1]}"
      break
    end
  end
end


