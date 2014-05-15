##require 'ostruct'
require_relative  "pseudo_digit"
require_relative  "jdx_structure"
require_relative  "core_ext"
require_relative  "switchies/case_switch"
#require_relative  "switchies/shamble"
require_relative  "switchies/output"


class Switchies
#todo  ntuple processing : data=[[indep][dep]]= [[T1,T2],[]
#  

 attr_reader :output,:stop, :flotr2_data, :tab_data,:sliced_tab_data
  include Data_structure
  include Pseudo_digit
  include Sweetcheese_case
  include Sweetcheese_switch
  #include Shambling 
  include Sweet_output
  
  def initialize(  option={})
   @stop =false
   temp=option[:process]
   neg_option_list=["extract","header","info", "spec", "param","data","uncl","comment"]
   option_to_case={ "extract" => :'case_extract',
                     "header"  => :'case_header'   ,
                    "info"    => :'case_sample_info'    ,
                    "spec"    => :'case_spec_param'    ,
                    "param"   => :'case_spectral_param'   ,
                    "data"    => :'case_data'    ,
                    
                    "uncl"    => :'case_uncl_ldr'    ,
                    "comment" => :case_comment  }
   
   option_list= neg_option_list + ["block","extract","point","extract_all","extract_first", "x_all","x_comment","x_multi"]
   @process_sym=option_list.map{|p| p.to_sym}
   @process={}
   option_list.each{ |opt|
            temp =~ /(#{opt})/  
            if $1
            neg_option_list -=  [$1]  
            tempa= ($' && $')||""
            tempa  =~ /#{option_list.join('|')}/
            @process[:"#{opt}"]=($` && $`.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip.split(/\s*(\#|,)+/ ))||tempa.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip.split(/\s*(\#|,)+/ ) #todo check regex 
            end
            }
 
   #@v=true #logging
    
    @exit = {:'Default' => -> {@line=nil}  }
   
   ### ground floor switch
    # @g =  { :'case_init_ldr'  => -> {f_log "@g:case_init_ldr"  if @v;switch_init_ldr},    #match ldr     ##
            # :'case_init_com'  => -> {f_log "@g:case_init_com"  if @v;switch_comment},    #match comment $$
            # :'case_multi_line'=> -> {f_log "@g:case_multi_line"if @v;switch_multi_line},
            # :'Default'        => -> {f_log "@g:default"        if @v;@line=nil}
          # }
    @g =  { :'case_init_ldr'  => -> {switch_init_ldr},    #match ldr     ##
            :'case_init_com'  => -> {switch_comment},    #match comment $$
            :'case_multi_line'=> -> {switch_multi_line},
            :'Default'        => -> {@line=nil}
          }      
    @g[:'case_init_ldr']= -> {reinitialize_extract;switch_init_ldr} if @process[:extract_all]   
    @h =@g         
   
   ### 1st floor switch : processing LDR
    @s1_all = {
            :'case_extract'        => -> {                                                        switch_extract},         #f_log "@s1:extract"       if @v;   
            :'case_header'         => -> { @s1=@s1_header;@key=:header;@temp_current = @block_current[:header];switch_header},         #f_log "@s1:header"        if @v;    #match LDR Regex_header                header 
            :'case_sample_info'    => -> { @s1=@s1_info  ;@key=:info  ;@temp_current = @block_current[:info]  ;switch_sample_info},    #f_log "@s1:sample_info"   if @v;    #match LDR Regex_sample_info           info
            :'case_spec_param'     => -> { @s1=@s1_spec  ;@key=:spec  ;@temp_current = @block_current[:spec]  ;switch_spec_param},     #f_log "@s1:spec_param"    if @v;    #match LDR regex_spec_param (variable) spec
            :'case_spectral_param' => -> { @s1=@s1_param ;@key=:param ;@temp_current = @block_current[:param] ;switch_spectral_param}, #f_log "@s1:spectral_param"if @v;    #match LDR Regex_spectral_param        param
            :'case_data'           => -> { switch_refact_param;                                                           #f_log "@s1:data"          if @v;    # 
                                           @s1=@s1_data  ;@key=:data  ;@temp_current = @block_current[:data]  ;switch_data},           #                                    #match LDR Regex_spectral_param        data
            :'case_uncl_ldr'       => -> {                @key=:uncl  ;@temp_current = @block_current[:uncl]  ;switch_uncl_ldr},       #f_log "@s1:uncl_ldr"      if @v;    #match LDR Regex_uncl_ldr           uncl
            :'case_comment'        => -> { @s1=@s1_com;switch_comment},                                                   #f_log "@s1:comment"       if @v;    #match comment                              com
            :'Default' => -> {@line=nil; @h =@g} #@ldr=nil;
          }
    
     @s1 = @s1_all
     @s1_extract  = {                                            
            :'case_extract'        => -> {switch_extract},       #  f_log "@s1:extract"       if @v; #match LDR Regex_header                header 
            #:'case_comment'        => -> switch_comment},       #  {f_log "@s1:comment"      if @v;            #match comment                         com
            :'Default'             => -> {@s1=@s1_all;@h=@s1}   #  f_log "@s1:default"       if @v 
                    }                                            #                                  
     @s1_header   = {                                                            #                                  
            :'case_extract'        => -> { switch_extract},                      #  f_log "@s1:extract"       if @v;
            :'case_header'         => -> { switch_header},                       #  f_log "@s1:header"        if @v; #match LDR Regex_header                header 
            #:'case_comment'        => ->  switch_comment},                      #  {f_log "@s1:comment"      if @v;             #match comment                         com
            :'Default'             => -> {@s1=@s1_all;@h=@s1;switch_check_spec} #f_log "@s1:default"       if @v;
                    }               
                    
     @s1_info   =  {
           :'case_extract'         => -> {switch_extract},    #   f_log "@s1:extract"       if @v;          
           :'case_sample_info'     => -> {switch_sample_info},#   f_log "@s1:sample_info"   if @v;             #match LDR Regex_sample_info           info
           #:'case_comment'         => ->  switch_comment},   #   {f_log "@s1:comment"       if @v;                         #match comment               com
           :'Default'              => -> {@s1=@s1_all;@h=@s1} #   f_log "@s1:default"       if @v;          
                    }                                         #                                             
     @s1_spec   =  {                                          #                                             
           :'case_extract'         => -> {switch_extract},    #   f_log "@s1:extract"       if @v;          
           :'case_spec_param'      => -> {switch_spec_param}, #   f_log "@s1:spec_param"    if @v;            #match LDR Regex_spec_param          
           #:'case_comment'         => ->  switch_comment},   #   {f_log "@s1:comment"       if @v;                         #match comment               com
           :'Default'              => -> {@s1=@s1_all;@h=@s1} #                               #f_log "@s1:default" if @v;
                    }                  
     @s1_param   = { 
           :'case_extract'         => -> { switch_extract},  #f_log "@s1:extract"       if @v;
           :'case_spectral_param'  => -> { switch_spectral_param}, #f_log "@s1:spectral_param"if @v; #match LDR Regex_spectral_param        param
           #:'case_comment'         => -> {f_log "@s1:comment" if @v;switch_comment},                     #match comment               com
           :'Default'              => -> {@s1=@s1_all;@h=@s1} #f_log "@s1:default" if @v;
                    }                 
     @s1_data     = {
           :'case_extract'         => -> {switch_extract},  #f_log "@s1:extract"       if @v; 
           :'case_data'            => -> { switch_data},     #f_log "@s1:data"          if @v;       #match LDR Regex_spectral_param        data
           #:'case_comment'         => -> {f_log "@s1:comment"       if @v; switch_comment},                     #match comment                         com
           :'Default'              => -> {@s1=@s1_all;@h=@s1}                                    #f_log "@s1:default" if @v;
                    }
     @s1_uncl_ldr  = { 
           :'case_extract'         => -> { switch_extract},
           :'case_uncl_ldr'        => -> {switch_uncl_ldr},        #match LDR Regex_uncl_ldr           uncl
           #:'case_comment'         => -> {f_log "@s1:comment"       if @v; switch_comment},                     #match comment                         com
           :'Default'              => -> { @s1=@s1_all;@h=@s1} 
                    }
     @s1_comment   = {
           :'case_extract'         => -> { switch_extract},
           :'case_comment'         => -> {switch_comment},         #match comment                         com             
           :'Default'              => -> { @s1=@s1_all;@h=@g} 
                    }

    
    #  switch  : processing datapoints
    @s31 = {
           :'case_31'              => -> {switch_31},  #match/retrieve x =  +/- 1234.56e+/-123
           :'case_init_ldr'        => -> { switch_check_out if @proc;@h=@s1},
           :'case_init_com'        => -> {switch_comment},
           :'Default'              => -> {@line=nil}
           }                      
    @s32 = {                      
           :'case_32'              => -> {switch_32},
           :'case_init_ldr'        => -> {switch_check_out if @proc; @h=@s1},
           :'case_init_com'        => -> {switch_comment},
           :'Default'              => -> {@line=nil}
           }
    @s30 = {                      
          
           :'case_init_ldr'        => -> {@h=@s1},
           :'case_init_com'        => -> {switch_comment},
           :'Default'              => -> {@line=nil}
           }   
   
   ##
   ##
   
   if neg_option_list.to_a.size  > 0 && neg_option_list.size != 8
      neg_option_list -= ["data"] if @process[:point]
      neg_option_list -= ["extract"] if @process[:extract_first] || @process[:extract_all]
      neg_option_list.each{|opt|   @s1_all.delete(option_to_case[opt]) 
      if opt == "extract" 
        [@s1_header,@s1_info,@s1_spec,@s1_param,@s1_comment,@s1_uncl_ldr,@s1_data].each{|sweet|
             sweet.delete(option_to_case[opt]) }
      end
      }
   end
   
  line=""  
  if neg_option_list.size==8
     @s1_all.delete(option_to_case["extract"])
    neg_option_list.each{|opt| @process[:"#{opt}"]=[]}
  end
   line << "\n@process: #{@process} \nneg_option_list = #{neg_option_list}"
   line << "\n@s1_all = #{@s1_all}"
   
   @x_multi   = true if @process[:x_multi]
   @x_com = true if @process[:x_comment]
   @x_com,@x_multi=true,true if  @process[:x_all]
   
   ### processing of datapoint
   @proc=false
   if @process[:point] && @process[:point].to_s =~ /(raw)/i || neg_option_list.size== 7
     @proc=$1
   end
   # line << "\n @proc is true  :    processing of #{$1} datapoints "     if @proc
   # line << "\n @proc is false : no processing of  datapoints "          if !@proc 
   ####
   
   @block=0    
   @precision = (option[:precision].to_i != 0  && option[:precision].to_i) || nil
   
   ##other instance variable def
   @output=Rapere.new   
     @regex_extract_dup = "|"
      [:extract,:extract_all,:extract_first].each{|s| @regex_extract_dup += @process[s].dup.compact.map{|e| e.strip}.uniq.join("|").gsub(/\s*[",]\s*/,"").gsub(/\|+/,"|") if @process[s]}
      @regex_extract_dup << "|"
   
   reinitialize_extract
   
   
  
   block_init
  
     
  end
  
  def stop_it
    @stop=true
  end
    
  def block_init(ldr=nil)
    
    line = "\ninit new block"
    if @output.size>0
    
    end
    
    if ldr && @block_current
      @block_current[:kai].kai_TITLE = ldr
    end
    if @process[:block]
      ## exit  if wanted blocked processed or skip if current block not wanted
    end
    
     #Regex_spectral_param_NMR
    reinitialize_extract unless @process[:extract_first]
      
    # line << "\nextraction of : #{@regex_extract}" if @regex_extract
   
    @output.init(@process) 
    
     
    
    @block_current=@output.last
    key=@key||:uncl
    @temp_current = @block_current[key]
    @kai=@block_current[:kai] #todo check if i can have thi  in the intitializer
    @raw=@block_current[:raw_point]
    @extract=@block_current[:extract]
    @processed=@block_current[:processed_point]
    @ntuple=0
    @temp = ""
    @temp_delta = 1  
    
 
  end
 def reinitialize_extract
      @regex_extract = @regex_extract_dup.dup
      
 end
  

  
  
   
  def sw(line)
    #return "exit" if @h == @exit 
    @line=line#.to_s.strip 
    while @line   #.to_s != ""  
      
      switch(@h)
    end
    
  end


 

   def output
    @output
   end
   
  def struct2h(i=nil)
    #merge structure into hash while removing empty field
    if i
    @output[i][:h]={}
    @process_sym.each{|s| @output[i][s].each_pair{|k,v| @output[:h][k]=v if !v.nil?}if @output[i][s]}   
    else
      @output.each{|block| 
      block[:h]={}
      @process_sym.each{|s| block[s].each_pair{|k,v| block[:h][k]=v if !v.nil?}if block[s]} } 
    end
  end
 
 def output4cw
   cw= {:ldr=>{},:y=>[]}
   @regex_extract_dup.split(/\|/).each{|s| s=s.to_sym;@output.each{|b| cw[:ldr][s]=b[:extract][s] || [] }}
  
   cw[:y]=(@output[-1][:raw_point][0] && @output[-1][:raw_point][0][:y])|| [0]
   cw
 end 

  def process_data(j=-1)
   @processed += Hua_point.new
   p=nil
   p=@precision
   symbol_ind=@kai.SYMBOL_INDEX.last[0..1] || [0,1]
   f=symbol_ind.map{|e| (@kai.FACTOR.fetch(e) && @kai.FACTOR.fetch(e).to_f) || 1 }   
                    
   @processed.last.x=data_str2arr(@raw.last.x,f[0],p)
   @processed.last.y=data_str2arr(@raw.last.y,f[1],p)
   
  end
   
   def data_str2arr(str="",factor=1,precision=16)
     
   cond = ->(f=1){ f != 0 && f != 1}
   str=str.split(" ") if str.is_a?(String) #moved this to switcch 3.1
   data_arr=str.dup
    if data_arr.is_a?(Array)
    if cond.call(factor) && precision != 16
       data_arr.map!{|x| x  = x.to_f
                     x *= factor  
                     x  = x.to_d(precision) 
                     x.to_f}
    elsif cond.call(factor) && precision == 16
          data_arr.map!{|x| x  = x.to_f
                     x *= factor
                     x.to_f}
    elsif precision == 16  && !cond.call(factor)
          data_arr.map!{|x| x  = x.to_f 
                     x  = x.to_d(precision) 
                     x.to_f}
    else  data_arr.map!{|x| x  = x.to_f }
    end 
    end
  end
  
  def strawberry
    @tab_data=@output.to_ro
    temp=@tab_data.detect_and_fill
   
    temp=temp.slice_4ldr(:raw_point)
    @flotr2_data=temp.to_flotr2
    
    @flotr2_data
  end
  
  def kumara(data=@flotr2_data)
      data.to_kumara
      data
  end
    
end