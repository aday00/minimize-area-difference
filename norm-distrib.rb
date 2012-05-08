#!/usr/bin/env ruby

#inputs
$mean = 40
$stdev = Math.sqrt(0.2)
$amp = 0.8
$range = 20
$min = 30
$max = 70

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
