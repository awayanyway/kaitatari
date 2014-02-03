#!/usr/zbin/env ruby

### Kaitātari

#require "rubygems"
require_relative "kaitatari/version"
require_relative "kaitatari/core_ext"
require_relative  "kaitatari/jdx_structure"
require_relative  "kaitatari/pseudo_digit"
require_relative  "kaitatari/switchies"

class Jcampdx
  
  include Data_structure
  #include Switchies
  include Pseudo_digit

  attr_accessor  :file, :data_output ,:option_hash
  attr_reader :option_list, :output
  
  def initialize(option={}) 
 
    @option_hash={:temp => []}
 
    if option.is_a?(String)
      
      option =    option.gsub(/-\b/,":").split(/\s(?=[:]w+)| +/)
      option= option.map{|e|
        e=~/^[:]/
        e=($' && $'.rstrip.to_sym) || e }
    else option =  option.flatten.flatten
    end

    
    first= "temp".to_sym
    while option != []
      while option != [] && (second= option.slice!(0)).class != Symbol
        (@option_hash[first]||=[])<<second
      end
      @option_hash[first] = ["on"] if (first == :output && @option_hash[first] = [])
      first = second
    end
    @option_hash.each_pair{|k,v| option_hash[k]=v.join(",").rstrip.chomp}
    
   @option_hash[:filename] ||= "TEST.DX" #todo unless :file then file =~ /\/([^ \t\n\r\/]+)\z/ filename=$1
   @option_hash[:path] ||= "#{__FILE__}".gsub(/lib\/kaitatari\.rb\z/,"samples")
   @option_hash[:file] ||= "#{@option_hash[:path].to_s}/#{@option_hash[:filename]}"
   @option_hash[:output_path] ||= @option_hash[:path]
   @option_hash[:output_filename] ||= "#{@option_hash[:filename]}".gsub(/(\.[jJ]?[dD][xX])+\z/,".kaitatari")
   @option_hash[:output_file] ||= "#{@option_hash[:output_path].to_s}/#{@option_hash[:output_filename]}"
   @option_hash[:temp] = nil
   
   @file = @option_hash[:file]
   @output_file = @option_hash[:output_file] || nil
   @process     = @option_hash[:process]     || nil
   @extract     = @option_hash[:extract]     || nil
   @output      = @option_hash[:output]      || nil
   
   
   
   @option_list = Hash["filename"," name of the jdx file to process ",
        "path", "path for input and output file ,default is ../samples/ ",
        "output","output a text file of the jdx processing ",
        "output_filename",  " default is inputname.kaitatari ",
         "output_path",  " default is inputpath ",
        "process", "off | all (default) | headers | param | block n (=integer) 
                  headers and params can be followed by: all | unclassified ",                                         
             "extract",  "[Label Data Reccord,..] (any LDR, will look for LDR, .LDR and  $LDR)",
             "verbose", "  ...  (for development mode)"   ]
    
    end
    
    
    def show_option   
      puts "actual options  : "
      @option_hash.each_pair{|k,v| puts " "*(15-k.to_s.size)+"@#{k} = #{v}"} 
      puts "possible options :"
     @option_list.each_pair{|k,v| puts " "*(15-k.to_s.size)+"@#{k} = #{v}"} 
    end
    
   

   


  
  
 def self.load_jdx(*p)
   jdx_file = self.new(p)
   jdx_file.show_option
   wait=gets
   jdx_file.processor unless @process =~ /off|no/
   puts "output #{@output}"
   jdx_file.test_output_file if jdx_file.output
   puts "now writing #{@output_filename}" if jdx_file.output 
   puts "data #{jdx_file.data_output}"
 end  


   def test_output_file
     ofile=File.new(@output_file, "w+")
     format = [20, 20].map{ |a| "%#{a}s" }.join(" ")  
     @data_output[0..2].each{|struct| 
                 #puts "now writing structure #{struct.class}"
                  struct.each_pair{|k ,v| ofile.write("#{" "*(30-k.to_s.size)}#{k}  =  #{v} \n" )}}                                                          #c=0
     @data_output[-2].zip(@data_output[-1]).each {|a| 
                           ofile.write("#{a[0]}#{" "*(20-a[0].to_s.size)} #{a[1]} \n ")
                   #ofile.write(" #{format % a} \n") #if c.modulo(3) == 0.0}  ##sampling point  
                         }
     #puts "closing file"
     ofile.close
   end
              
   def processor(file)
     #rank = 0 #ldr marker
     puts __method__
     puts file
     option=[ @process,@extract]
     line_switcher=Switchies.new(option)
     File.foreach(file) do |line|                                               
     line_switcher.sw(line) 
     end
     puts __method__
     #puts line_switcher.output
    @data_output =line_switcher.output
      line_switcher.output
   end  

end