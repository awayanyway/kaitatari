#!/usr/zbin/env ruby
# encoding: utf-8

### Kaitātari

#require "rubygems"
require_relative  "kaitatari/version"
require_relative  "kaitatari/core_ext"
require_relative  "kaitatari/jdx_structure"
require_relative  "kaitatari/pseudo_digit"
require_relative  "kaitatari/switchies"
require_relative  "kaitatari/postscript"
require 'yaml'



class Jcampdx
 #todo declare private & co ..
 
   
  include Data_structure
  #include Switchies
  include Pseudo_digit
  @@archive_path = "#{__FILE__}".gsub(/lib\/kaitatari\.rb\z/,"samples")
   attr_accessor :data_output #:option_hash
  attr_reader :option_list, :data_output,:option_hash

  def initialize(*p)  
   @data_output=[] 
   @option_hash={:temp => []}
   @option_list = Hash["filename", "name of the jdx file to process ",
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
                         "extract",  "[Label Data Reccord,..] (any LDR, will look for LDR, .LDR and  $LDR)"
                        ] 
   
   wicked_setup(*p)
   end
   
    
    
  def show_option   
    puts "kōwhiringa mō te tatāri o te kōnae :"
    @option_hash.each_pair{|k,v| puts " "*(15-k.to_s.size)+"@#{k} = #{v}"} 
  end
    
   
  def option_list
    puts "possible options :"
    @option_list.each_pair{|k,v| puts " "*(18-k.to_s.size)+"@#{k} = #{v}"}
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
    jdx_file.processor unless jdx_file.option_hash[:process] =~ /off|no/
    jdx_file.output_kaitatari if jdx_file.option_hash[:output]
    jdx_file.return_data
  end 
  
  def return_data
    return YAML.dump(self.data_output) if @option_hash[:return_as] =~ /yaml/
    return Marshal.dump(self.data_output)  if @option_hash[:return_as] =~ /marshal/
    return  ps_new if @option_hash[:return_as] =~ /ps|postscript/
    return self.data_output
  end
  
  def ps_new
    ps = Postscript_output.new({:data => @data_output})
     ps.build_ps
     ps.output_text
  end
  
  def self.marshal_load(data)
    Marshal.load(data)
  end 
   
  def processor
    puts "#{__method__}: with #{@option_hash[:file]}"
    file=@option_hash[:file]
    line_switcher=Switchies.new(@option_hash)
    File.foreach(file){|line|  line_switcher.sw(line)}
    puts "#{__method__}: processing file over"
    @data_output=line_switcher.output 
  end

  def output_kaitatari
    output_rb      if @option_hash[:output]  =~ /\s*(on| rb|ruby)\s*/
    output_txt     if @option_hash[:output]  =~ /\s*(text|txt)\s*/
    output_yaml    if @option_hash[:output]  =~ /\s*yaml\s*/
    output_marshal if @option_hash[:output]  =~ /\s*(msh|marshal)\s*/
    output_ps      if @option_hash[:output]  =~ /\s*(ps|postscript)\s*/
  end
   
   def output_rb
     temp = @data_output.to_s
     temp = temp.gsub(/,/,",\n")
     file = @option_hash[:output_file] + ".rb"
     ofile=File.new(file, "w+")
     ofile.write temp 
     puts "#{__method__} in file: #{file}"
     ofile.close
     temp
   end
   
   def output_marshal
     #todo
     temp = Marshal.dump(@data_output)
     file = @option_hash[:output_file] + ".msh"
     ofile=File.new(file, "w+")
     ofile.write temp 
     puts "#{__method__} in file: #{file}"
     ofile.close
     temp
   end
   
   def output_yaml
     temp=YAML.dump(@data_output)
     file = @option_hash[:output_file] + ".yaml"
     ofile=File.new(file, "w+")
     ofile.write temp 
     puts "#{__method__} in file: #{file}"
     ofile.close
     temp
   end   
           
   def output_text
     temp=""
     @data_output.each{|block| 
                        block[0].each_pair{|k ,v| temp << "#{" "*(30-k.to_s.size)}#{k}  =  #{v} \n" }                                                         #c=0
                        block[1][-2].zip(block[1][-1]).each {|a| temp << "#{a[0]}#{" "*(20-a[0].to_s.size)} #{a[1]} \n " } 
                       }
     file = @option_hash[:output_file] + ".txt"
     ofile=File.new(file, "w+")
     #format = [20, 20].map{ |a| "%#{a}s" }.join(" ")  
     ofile.write(temp) #if c.modulo(3) == 0.0}  ##sampling point
     puts "#{__method__} in file: #{file}"
     ofile.close
     temp
   end
   
   
   def output_jdx
     file = @option_hash[:output_file] + ".jdx"
     ofile=File.new(file, "w+")
     format = [20, 20].map{ |a| "%#{a}s" }.join(" ")  
     @data_output.each{|block|
                        block[0].each_pair{|k ,v| ofile.write("###{k}=#{jdx_format(v)} \n" )}                                                         #c=0
                        block[1][-2].zip(block[1][-1]).each {|a| ofile.write("#{a[0]} #{a[1]} \n ")}
                        }   
     puts "#{__method__} in file: #{file}"
     ofile.close
   end
 
   def output_ps
     block_counter=0
      #select first block with  data
      while block_counter <@data_output.size
        b ||= block_counter if @data_output[block_counter][1][0] != []
        block_counter += 1
      end 
     ps = Postscript_output.new({:data => @data_output[b]})
     ps.build_ps
     file = @option_hash[:output_file] + ".ps"
     ofile=File.new(file, "w+")
     ofile.write(ps.output_text)
     puts "#{__method__} in file: #{file}"
     ofile.close
     
   end
   
   private
 
   def wicked_setup(*a)
    #wicked  treatment of args
    
    temp_hash={:temp => []}
   #.gsub(/\s-\b/,":")
    a=a.to_s.gsub(/[;'"<>=*&%\^$#\@~`|,\[\]\{\}]/, " ").gsub(/\s+/," ").split(/(?<=\w) (?=:\w)/).map{|e| e=[$1.to_sym,$'.lstrip.rstrip] if e =~ /:(\w+)/}.flatten
    #puts "#{__method__}:2: a was #{a}"
    while a != []
           temp_hash[a.slice!(0)]=a.slice!(0)
    end
    @option_hash.delete(:file)
    @option_hash=@option_hash.merge(temp_hash)
    puts " #{__method__}:2:@option_hash now = #{@option_hash}"
    if @option_hash[:file] && !@option_hash[:file].to_s =~ /samples\/TEST/
       @option_hash[:filename] = File.basename(@option_hash[:file])
       @option_hash[:path]     = (@option_hash[:file] =~ /#{@option_hash[:filename]}\z/ && $`)
        puts "u re here if"  
    elsif @option_hash[:filename] #&& !@option_hash[:path] ||  
      @option_hash[:path] = @@archive_path  unless @option_hash[:path]
      puts "u re here elsif"
    else
       @option_hash[:filename] ||= "TEST.DX"  
       @option_hash[:path]     ||= @@archive_path
       puts "u re here else" 
    end
    @option_hash[:file]            ||= "#{@option_hash[:path].to_s}/#{@option_hash[:filename]}"
    @option_hash[:output_path]     ||= "#{@option_hash[:path]}"
    @option_hash[:output_filename] ||= "#{@option_hash[:filename]}".gsub(/(\.[jJ]?[dD][xX])+\z/,".kaitatari")
    @option_hash[:output_file]     = "#{@option_hash[:output_path].to_s}/#{@option_hash[:output_filename]}"
    @option_hash[:return_as]       ||= "ruby array"
    @option_hash.delete(:temp)
     
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
   
   def jdx_format(entry="")
     # limit line size to 80 charac, take array or string
     #todo do not slice in the middle of a word
     #todo process array type LDR entry e.g "##$P = (0..63) \n 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0...."
     str =( entry.is_a?(Array) && entry.join(","))|| entry
     temp=""  
     while str.to_s.size > 0
     (str =~ /\n+/ && (str ,str2 = $', $`)) || str2 = str
     while str2.to_s.size > 0 
     temp << str2.slice!(0..78) + "\n"
     end
     end
     temp.chomp
   end
end