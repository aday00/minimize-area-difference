#!/usr/bin/env ruby

#inputs
$min = -10
$max = 10
$step = 1
$amp = 1.0
$mean = 0.0
$stdev = Math.sqrt(0.2)

#constants
$sqrt2pi = Math.sqrt(2*Math::PI)

#derived results
$normcoeff = $amp / ($stdev * $sqrt2pi)

def norm(x)
  return $normcoeff*Math.exp(-0.5 * ((x - $mean)/$stdev)**2)
end
$min.upto($max) do |i|
  puts "#{i} #{norm(i)}"
end  
