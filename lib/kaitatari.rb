#!/usr/zbin/env ruby
# encoding: utf-8

### Kaitātari

#require "rubygems"
require_relative  "kaitatari/version"
require_relative  "kaitatari/core_ext"
require_relative  "kaitatari/jdx_structure"
require_relative  "kaitatari/pseudo_digit"
require_relative  "kaitatari/switchies"
require_relative  "kaitatari/output"
require_relative  "kaitatari/postscript"
require_relative  "kaitatari/log"
require 'yaml'

class Kai

include Pseudo_digit 
include Data_structure
include Output
include Sweet_output

 
attr_accessor :opt, :result, :type ,:flotr2_data
attr_reader :data
  
def initialize(opt)
  f_log
  opt=opt.to_s unless opt.is_a?(String)
  opt =~ /(:file)\s*(\w+|)?/
  return nil  unless $1
  @opt=$`+" :file "+$'
  @type=$2
  @result= case type 
  when "jdx"     then Jcampdx.new(@opt).processor_kai
  when "nmrbruk" then Topspin.new(@opt)
  when "yaml"    then Jcampdx.new(@opt).load_yaml.detect_and_fill
  end
 
  if @result
    @flotr2_data=@result ||nil #.fill_header
  else
    #@flotr2_data="too early for strawberry season"
  end
  
end

def self.test_file(f,type=nil)
 f=f.to_s.strip
 if !type && File.file?(f)
   
   answer=File.file?(f)
 
 elsif f  =~ /\|/ && file=$'
  
   if file.to_s != "" && file =~ /\|/
   file= ""
   file=$` if $`
   end
   answer= File.file?(file)
 end
 
 
 if type && answer
   f.to_s  =~ /\|/ && t=$`
   answer=(type == t)
 end
 answer
end

def data
  @data=@result.data_output
end

def self.load(opt)
  opt=opt.to_s unless opt.is_a?(String)
  opt =~ /(:file)\s*(\w+|)?/
  return "no input file"  unless $1
  opt=$`+" :file "+$'
  type=$2
 
  result= case type 
  when "jdx"     then Jcampdx.load_jdx(opt)
  when "nmrbruk" then Topspin.load_file(opt)
  when "yaml"    then Jcampdx.load_yaml(opt)
  end
  result 
end



end


class Topspin
  def self.load_file(*p)
    jdx_file = self.new(*p)
    jdx_file.processor if jdx_file.option_hash[:process]
    jdx_file.output_kaitatari if jdx_file.option_hash[:output]
    jdx_file.return_data
  end 
end

class Jcampdx
 #todo declare private & co ..
 
  include Pseudo_digit 
  include Data_structure
  include Output
  include Sweet_output
  
  @@archive_path = "#{__FILE__}".gsub(/lib\/kaitatari\.rb\z/,"samples")
  @@log_path = @@archive_path + "/kaitatari.log"
  @@logging = false
  
  attr_accessor :data_output #,:option_hash
  attr_reader   :option_hash ,:ldr,:processed_points,:points,:tab_data #,:data_output,:option_list
  
  def initialize(*p)   
   t=Time.now 
   
   @data_output=[] 
   @option_hash={:temp => []}
   @output_list=["rb","txt","yaml","marshal", "ps", "cw","lsi"]
   wicked_setup(*p)
   
   if @option_hash[:logging]
      @@logging = true
   end
   
   f_log(false)
   f_log p.to_s
   f_log "started at #{t}"
  end
   
    
    
  def show_option   
   line="\nkōwhiringa mō te tatāri o te kōnae :\n"
   
    
    @option_hash.each_pair{|k,v| line << " "*(15-k.to_s.size)+"@#{k} = #{v}\n"} 
    puts line
    f_log(line,-1)
  end
     
  def option_list
    puts "possible options :"
    option_list = Hash["filename", "name of the jdx file to process ",
                            "path", "path for input and output file ,default is ../samples/ ",
                          "output", " ruby  | yaml |jdx | ps
                           output a rb/yaml/jdx / postscript file of the jdx processing ",
                          "return_as", "ruby (default) | yaml 
                       return a ruby-object/yaml-text of the jdx processing ",
                 "output_filename", "default is inputname.kaitatari ",
                     "output_path", "default is inputpath ",
                "output_precision", "integer (default is 8 significant digit) ",
                         "process", "off | all (default) | headers | param | block n (=integer) 
                  headers and params can be followed by:   class |unclassified|   ", # Bruker....                                         
                        # "extract",  "[Label Data Reccord,..] (any LDR, will look for LDR, .LDR and  $LDR)"
                        "log","off | on (log in @@archive_path/kaitatari.log)"
                        ] 
   
    option_list.each_pair{|k,v| puts " "*(18-k.to_s.size)+"@#{k} = #{v}"}
    puts ".. "
  end
  
  def option(*add_key_value)
   wicked_setup(add_key_value)
  end

  def self.archive_path(path_to_data)
    @@archive_path=File.path(path_to_data)
  end

   
  def self.load_jdx(*p)
    jdx_file = self.new(*p)
    jdx_file.processor if jdx_file.option_hash[:process]
    
    jdx_file.output_kaitatari if jdx_file.option_hash[:output]
    jdx_file.return_data
  end 
  
  def self.load_jdx4cw(*p)
    jdx_file = self.new(*p)
    jdx_file.processor_cw 
  
  end 
     

  
  def ps_generator
 
    temp=@tab_data.slice_4ldr(:raw_point).to_flotr2.to_kumara.chip_it
   
    
   tempxy=temp.xy
    if temp.xaxis_reversed
      
      xy=tempxy.transpose
      tempxy=xy[0].zip(xy[1].reverse)
      
    else
       
    end
    opt={
     :data_xy => tempxy,
     :resolution => 600,
    }
    
    output_cw(opt) 
  end
  
  def load_yaml
    temp=File.read(@option_hash[:file],{:external_encoding=>"ASCII-8BIT" })
    #@yaml=YAML.load(temp)
    @yaml=Marshal.load(temp)
    puts "loaded marshal:"+@yaml.inspect.slice(0..30)
    @tab_data=Switchies::Ropere.new(@yaml)
    
  end
  def self.load_yaml(*p)
    jdx_file = self.new(*p)
    jdx_file.load_yaml
    jdx_file.return_data
    
  end
  
  def self.load_yaml_2_ps(*p)
     j = self.new(*p)
     j.load_yaml
     j.ps_generator
  end
  
  
  def return_data
    if @option_hash[:return_as] =~ /yaml/
      r= YAML.dump(self.data_output) 
    elsif @option_hash[:return_as] =~ /marshal/
      r= Marshal.dump(self.data_output)  
    #r=  ps_new elsif @option_hash[:return_as] =~ /ps|postscript/
    elsif  @option_hash[:return_as] =~ /kumara/
      r= self.tab_data.slice_4ldr(:raw_point).to_flotr2.to_kumara 
    else 
      r= self.data_output
    end
    r
  end
  

  def processor_main
   
    file=@option_hash[:file]
    switcher=Switchies.new(@option_hash)
    count=0
    File.foreach(file){|line| 
                     
                      switcher.sw(line)
                      break if switcher.stop }
    switcher
  end
  
  def processor
    switcher=processor_main
    @data_output=switcher.output 
    @tab_data= switcher.strawberry
    
  end
  
  def processor_kai
    switcher = processor_main
    @data_output=switcher.output
    @tab_data= switcher.strawberry
  end
  
  def processor_cw
    switcher     = processor_main
    #data=switcher.output4cw
    #return "got no data" if data[:y]==[0]
    @data_output=switcher.output #data
    #opt={:data_y => data[:y], :ldr => data[:ldr] }
    output_cw()
    puts "done with processor_cw" 
  end


  def output_kaitatari
   
    
    return if !@option_hash[:output].is_a?(Hash)
    @output_list.each{|o| 
                           if @option_hash[:output][o.to_sym]
                           #f_log "refact option before output_#{o}"
                           puts "output #{o}"
                           ref_output_option(o.to_sym)
                           eval("output_#{o}") 
                           end }
  end

   
   private
 
   def wicked_setup(*a)
    #wicked  treatment of args
    
     temp_hash={:temp => []}
     a=a.to_s.gsub(/[;'"<>=*&%\^$\@~`|\[\]\{\}]/, " ").gsub(/\s+/," ").split(/(?<=\w) (?=:\w)/).map{|e| e=[$1.to_sym,$'.lstrip.rstrip] if e =~ /:(\w+)/}.flatten
     while a != []
           temp_hash[a.slice!(0)]=a.slice!(0)
     end
     @option_hash.delete(:file)
     @option_hash=@option_hash.merge(temp_hash)
     #f_log " @option_hash now = #{@option_hash}"
     if @option_hash[:file] #&& !File.basename(@option_hash[:file]).to_s =~ /TEST/
      
        @option_hash[:filename] = File.basename(@option_hash[:file])
        @option_hash[:path]     = File.dirname(@option_hash[:file])   #(@option_hash[:file] =~ /#{@option_hash[:filename]}\z/ && $`)
        
     elsif @option_hash[:filename] #&& !@option_hash[:path] ||  
       @option_hash[:path] = @@archive_path  unless @option_hash[:path]
     
     else
        @option_hash[:filename] ||= "TEST.DX"  
        @option_hash[:path]     ||= @@archive_path
     end
     @option_hash[:file]            ||= "#{@option_hash[:path].to_s}/#{@option_hash[:filename]}"
     @option_hash[:output_path]     ||= "#{@option_hash[:path]}"
     @option_hash[:output_filename] =  @option_hash[:filename] unless @option_hash[:output_filename]
     @option_hash[:output_filename] ||= "#{@option_hash[:filename]}".gsub(/(\.[jJ]?[dD][xX])+\z/,".kaitatari")
     @option_hash[:output_file]     = "#{@option_hash[:output_path].to_s}/#{@option_hash[:output_filename]}" unless @option_hash[:output_file]
     @option_hash[:return_as]       ||= "ruby array"
     @option_hash.delete(:temp)
     
     ##output_option={}
     if @option_hash[:output]
        temp=@option_hash[:output].dup
        @option_hash[:output]={}
        @output_list.each{ |opt|
             temp =~ /(#{opt})/  
             if $1 
                tempa= ($' && $')||""
                tempa  =~ /#{@output_list.join('|')}/
                @option_hash[:output][:"#{opt}"]=($` && $`.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip)||tempa.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip #todo check regex 
             end
             }
       
      
     end 

     # self.show_option
  end
   
   
 

   
end