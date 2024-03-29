#!/usr/bin/env ruby

#inputs
$mean = 53
$stdev = Math.sqrt(5.0)
$amp = 3.5
$min = 20
$max = 80
$noise_level = 1.5

#constants
$sqrt2pi = Math.sqrt(2*Math::PI)

#derived results
$normcoeff = $amp / ($stdev * $sqrt2pi)

def norm(x)
  return $normcoeff*Math.exp(-0.5 * ((x - $mean)/$stdev)**2)
end
$min.upto($max) do |i|
  amt = norm(i)
  amt += (amt/$amp)*((rand - 0.5)*2)*$noise_level if amt > 0 # noise signal if greater than zero, and noise more as amt higher
  amt = 0 if amt < 0 # don't push signal below zero, doesn't make sense to have a negative amount of something in our context of counting the amount of reads of a particular range/bin of gc content
  puts "#{i} #{amt}"
end  
