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
  when "jdx"     then Jcampdx.new(@opt)
  when "nmrbruk" then Topspin.new(@opt)
  end
  f_log @result.class
  if @result
    @flotr2_data=@result.processor_kai #.fill_header
   
  end
  
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
  @@logging = true
  
  attr_accessor :data_output #,:option_hash
  attr_reader   :option_hash ,:ldr,:processed_points,:points,:tab_data #,:data_output,:option_list
  
  def initialize(*p)   
   t=Time.now 
   
   @data_output=[] 
   @option_hash={:temp => []}
   @output_list=["rb","txt","yaml","marshal", "ps", "cw"]
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
  
  def return_data
    return YAML.dump(self.data_output) if @option_hash[:return_as] =~ /yaml/
    return Marshal.dump(self.data_output)  if @option_hash[:return_as] =~ /marshal/
    return  ps_new if @option_hash[:return_as] =~ /ps|postscript/
    return self.data_output
  end
  

  def processor_main
   
    file=@option_hash[:file]
    switcher=Switchies.new(@option_hash)
    count=0
    File.foreach(file){|line| 
                     
                      switcher.sw(line)
                      break if switcher.stop }
    f_log "processing file over @ #{Time.now}"
    switcher
  end
  
  def processor
    switcher=processor_main
    #switcher.struct2h
    @data_output=switcher.output 
    
  end
  
  def processor_kai
    switcher = processor_main
    @tab_data_output= switcher.strawberry
    @data_output=switcher.output
    @tab_data_output
  end
  
  def processor_cw
    switcher     = processor_main
    data=switcher.output4cw
    @data_output=data
    opt={:data_y => data[:y], :ldr => data[:ldr] }
    output_cw(opt)
    puts "done with processor_cw" 
  end

  def output_kaitatari
    return if !@option_hash[:output].is_a?(Hash)
    @output_list.each{|o| 
                           if @option_hash[:output][o.to_sym]
                           #f_log "refact option before output_#{o}"
                           
                           ref_output_option(o.to_sym)
                           eval("output_#{o}") 
                           end }
    
    # output_rb      if @option_hash[:output]  #=~ /\s*(rb|ruby)\s*/
    # output_txt     if @option_hash[:output]  #=~ /\s*(text|txt)\s*/
    # output_yaml    if @option_hash[:output]  #=~ /\s*yaml\s*/
    # output_marshal if @option_hash[:output]  #=~ /\s*(msh|marshal)\s*/
    # output_ps      if @option_hash[:output]  #=~ /\s*(ps|postscript)\s*/
    # output_cw      if @option_hash[:output]  #=~ /\s*(cw)\s*/ #carierewave

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
     #@file        = @option_hash[:file]
     #@output_file = @option_hash[:output_file] || nil
     #@process    = @option_hash[:process]     || nil
     #@extract    = @option_hash[:extract]     || nil
     #@output      = @option_hash[:output]      || nil
     #@return_as   = @option_hash[:return_as]   || nil 
      self.show_option
  end
   
   
 
 # def data_output=(new_val)
   #  @data_output=new_val
  # end
  
  # def self.marshal_load(data)
    # Marshal.load(data)
  # end 
   
end