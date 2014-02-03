#!/usr/zbin/env ruby

require "../lib/kaitatari"

if __FILE__ == $0
  
#Jcampdx.load_jdx("TEST.DX", {:verbose => {:v => "wait", :v_s =>"wait", :v_m =>"wait"}})
#Jcampdx.load_jdx("TEST.DX", {:verbose => {:v => "wai"}})
Jcampdx.load_jdx(:output, "on")

puts "well done!"
        
end

