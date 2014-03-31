#!/usr/zbin/env ruby

require "../lib/kaitatari"

if __FILE__ == $0
  
#output=Jcampdx.load_jdx(":filename TW_48.dx :output ps :output_filename graph :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":filename TW_48.dx :output rb ps  :output_filename ruby :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/1D1H.dx :output rb  :process  header :output_filename ruby2 :output_path /home/pi/Desktop")
output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/BRUKNTUP.DX :output rb   :process param data :output_filename ruby-ntup :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":filename 1D1H.dx :process  header param :output rb :output_filename ruby :output_path /home/pi/Desktop")
puts "title : #{output[0][0][:TITLE]}"
#j=Jcampdx.new(":filename TW_48.trunc.dx  :output_path /home/pi/Desktop")
#j=Jcampdx.new(":filename blckpkt1.jdx  :output  ps :output_path /home/pi/Desktop")
#j=Jcampdx.new(":filename 1D1H.dx   :output_path /home/pi/Desktop")
#j.show_option
#j.option(:filename,"TW_48.dx")
#j.option({:return_as => "yaml"})
#j.show_option
#j.option(":precision 5")

#j.return_data
#j.output_yaml
#j.option(":return_as  ruby")
#j.option(":filename TW_48.dx :output  ps :output_path /home/pi/Desktop")
#j.show_option
#j.option(":return_as  ps")
#j.processor
#j.output_kaitatari
#j.output_marshal
#puts "#{j.return_data}"
#puts "#{j.data_output[1][1][0]}"
#j.output_text
#j.output_ps
#j.output_rb
puts "well done!"
        
end
