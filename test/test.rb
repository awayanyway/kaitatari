#!/usr/zbin/env ruby

require "../lib/kaitatari"

if __FILE__ == $0
  
#output=Jcampdx.load_jdx(":filename TW_48.dx :output rb :output_filename :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":filename TW_48.trunc.dx :output rb ps   :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":filename TEST.DX :output rb ps   :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/TW_48.trunc.dx :output  ps   ")
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/1D1H.dx :output rb  :process  header :output_filename ruby2 :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/BRUKNTUP_trunc.DX :output rb   :process param data :output_filename ruby-ntup :output_path /home/pi/Desktop")
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari/samples/BRUKNTUP_trunc.DX :output rb  :output_filename ruby-nt :output_path /home/pi/Desktop")

#output=Jcampdx.load_jdx(":filename 1D1H.dx :process  header param :output rb :output_filename ruby :output_path /home/pi/Desktop")
#puts "title : #{output[0][0][:TITLE]}"                                                               #ps ldr extract margin 0 0.1 data_y raw
#output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari20140311/samples/1D1H.dx :logging y :output rb    :process  extract OWNER,.OBSERVE FREQUENCY,.NUCLEUS,.AVERAGES param data point raw :output_path /home/pi/Desktop")
# output=Jcampdx.load_jdx(":file /home/pi/workspace/kaitatari20140311/samples/BRUKNTUP.DX :logging y :output rb    :process extract TITLE, TITLE, OWNER,.OBSERVE FREQUENCY  param data point raw first :output_path /home/pi/Desktop")
# puts "title : #{output[0][:spec] && output[0][:header][:TITLE]|| "no title" }"
# 
# output.each_with_index{|output,i|
  # puts output[:extract]
  # puts "title: #{(output[:extract] && output[:extract][:"TITLE"]) || "no TiTLE extracted"}" 
# puts "obs freq in block #{i} : #{output[:extract] && output[:extract][:".OBSERVE FREQUENCY"] || "no obs freq extractec"}"}

#  puts "t: #{output}"
#j=Jcampdx.new(":file /home/pi/workspace/kaitatari/samples/TW_48.trunc.dx   :output_path /home/pi/Desktop")
 extract_label="TITLE, DATA TYPE,.OBSERVE NUCLEUS,.SOLVENT NAME,.PULSE SEQUENCE,.OBSERVE FREQUENCY"
#j=Jcampdx.new(":file /home/pi/workspace/kaitatari20140311/samples/1D1H.dx :process extract #{extract_label} extract_first   :output_path /home/pi/Desktop")
file="/home/pi/workspace/kaitatari20140311/samples/1D1H.dx"
file="/home/pi/workspace/kaitatari20140311/samples/BRUKNTUP.DX" 
#file="/home/pi/workspace/kaitatari20140311/samples/blckpac1.jdx" 
#file="/home/pi/workspace/kaitatari/samples/blckpkt1.jdx" 
fileo="/home/pi/workspace/kaitatari/samples/blckpkt1-.jdx" 
#file="/home/pi/workspace/kaitatari20140311/samples/small2.jdx" 

#file="/home/pi/workspace/kaitatari/samples/chart.jdx"
#file ="/home/pi/workspace/lsi-rails-prototype/tmp/upload/1402479917-4158-0449/chart.jdx"
#fileo ="/home/pi/workspace/lsi-rails-prototype/tmp/upload/1402479917-4158-0449/charto.jdx"
#fileo= "/home/pi/workspace/lsi-rails-prototype/tmp/upload/1402477023-2035-1977/jdx_blckpac1.jdx"

 a=Jcampdx.load_jdx(":file #{file} :process  point raw :output lsi :output_file #{fileo} ")

 jdx_data = Kai.new(":file yaml|#{fileo}").result 
        @kumara= Kai.load(":file yaml|#{fileo} :return_as kumara")
       #  puts "~"*60+"\n"+@kumara.inspect.slice(0..200)+"\n"+"~"*60

       
         m     = jdx_data.detect(:method)
        puts "hello method #{m}"
        puts "hello title #{jdx_data.detect(:title)}" 
 
Jcampdx.load_yaml_2_ps(":file #{fileo} ")
# puts "testfile"
# puts File.file?(file)
# puts Kai.test_file(file)
# puts Kai.test_file("jdx|#{file}","jdx") 
# puts "testfile over"
#process_opt="header uncl spec param data"

#@dx_data=Kai.new(":logging y  :file jdx|#{file} :tab all :process #{process_opt} point raw :output rb ps data_y raw   :output_path /home/pi/Desktop/output_ps"  )
#@dx_data=Kai.load(":logging y  :file jdx|#{file} :tab all :process #{process_opt} point raw :output rb ps data_y raw   :output_path /home/pi/Desktop/output_ps"  )

# @dx_data.result.output_kaitatari
#puts @dx_data.class
#puts @dx_data.flotr2_data.class
#puts @dx_data.flotr2_data.respond_to?(:to_kumara)
#puts @dx_data.flotr2_data.key?(:x_reversed)
#d=@dx_data.flotr2_data


#d=d.to_kumara
#d.xy=nil
#f_log d.inspect
#puts d.chip_it(1..15)



#j.processor_cw
#puts j.data_output.last[:ldr]
#puts j.data_output.last[:y][0..10]
#j.processor
#puts j.data_output[0][:header][:OWNER]
#puts j.data_output[0][:extract]
#j=Jcampdx.new(":file /home/pi/workspace/kaitatari20140311/samples/1D1H.dx :output   rb                      :output_path /home/pi/Desktop")

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
#j.output_rb
#j.output_ps


puts "well done!\n"+"      ~~~~~~"*7
        
end


