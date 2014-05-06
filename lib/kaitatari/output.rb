

module Output
  include Data_structure
   def output_rb
     temp = @data_output.to_s
     temp = temp.gsub(/,/,",\n")
     file = @option_hash[:output_file] + ".rb"
     ofile=File.new(file, "w+")
     ofile.write temp 
     f_log " in file: #{file}"
     ofile.close
     temp
   end
   
   def output_marshal
     #todo
     temp = Marshal.dump(@data_output)
     file = @option_hash[:output_file] + ".msh"
     ofile=File.new(file, "w+")
     ofile.write temp 
     f_log " in file: #{file} @ #{Time.now}"
     ofile.close
     temp
   end
   
   def output_yaml
     temp=YAML.dump(@data_output)
     file = @option_hash[:output_file] + ".yaml"
     ofile=File.new(file, "w+")
     ofile.write temp 
     f_log " in file: #{file} @ #{Time.now}"
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
     f_log " in file: #{file} @ #{Time.now}"
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
     f_log " in file: #{file} @ #{Time.now}"
     ofile.close
   end
   
   def ref_output_option(temp)
    return if !@option_hash[:output]
    if temp.is_a?(Symbol)
     sym=temp
     temp=@option_hash[:output][sym] 
    end  
    return if temp.is_a?(Hash) || !temp
    option_list=[  "block",
                   "size" ,        #ps
                   "resolution",   #ps
                   "orientation",  #ps
                   "margin",         #ps
                   "data_x" ,      #ps
                   "data_y",
                   #"data",       #ps
                   "ldr",          #ps
                   "param",        #ps
                   "x1",           #ps 
                   "x2",           #ps
                   "y1",           #ps
                   "y2",           #ps
                   "z",            #ps
                   "page",         #ps
                    "point",
                    ]

    opt={} 
    option_list.each{ |o|
           temp  =~ /(#{o})/  
           if $1 
              tempa = ($' && $') || ""
              tempa =~ /#{option_list.join('|')}/
              opt[:"#{o}"]=($` && $`.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip)||tempa.to_s.gsub(/[^ \$\.,\d\w#]/," ").strip #todo check regex 
           end
        }
    #f_log "#{opt}" 
    
    #######
    
    #######
    opt[:block] = (opt[:block].is_a?(Integer) && opt[:block]) || find_data_block 
    b = opt[:block] ||  0 
    opt[:ldr] ||= @data_output[b][:h] && @data_output[b][:h] 
    if opt[:ldr].is_a?(String)
      if opt[:ldr] =~ /(\w+)/
        opt[:ldr]= @data_output[b][$1.to_sym] && @data_output[b][$1.to_sym]
      end 
    end
    opt[:page] ||= 0
    p=opt[:page]
    symb=[:x,:y]
    [:data_x,:data_y].each_with_index{|s,i| if opt[s].is_a?(String) && opt[s] =~/(raw|processed)/ 
                           
                           s2,s3="#{$1}_point".to_sym,symb[i]
                           opt[s]=(@data_output[b] && @data_output[b][s2] && @data_output[b][s2][p] && @data_output[b][s2][p][s3] )||nil 
                           end }
    opt[:data]=@data_output[b]  if opt[:data].is_a?(String) && opt[:data] =~/\s*first\s*/
    opt[:data]=@data_output[$1] if opt[:data].is_a?(String) && opt[:data] =~/\s*(\d+)\s*/ && ($1 < @data_output.size)
    opt[:data]=@data_output[$1] if opt[:data].is_a?(String) && opt[:data] =~/\s*all\s*/
    
    if opt[:margin].is_a?(String)
       opt[:margin] = opt[:margin].split(/ \s*/).slice(0..1).map{|e| e=e.to_f
                                                              e=0.0 if  e<0 || e>1 
                                                               e}
    end
    ###log
    opt2=opt.dup
    opt2[:data_x]=opt2[:data_x][0] if opt2[:data_x]
    opt2[:data_y]=opt2[:data_y][0] if opt2[:data_y] 
    
    ###
    
   @option_hash[:output][sym]=opt if sym
   opt
   #option_list={
   #  :block     => 0
   #  :size      =>   [11.7,8.3,"inch"] ,  #[width height,unit(inch|mm|cm|m)]
   #  :resolution=>   600.0,               # 72 dpi
   #  :orientation=> 0 ,                   #
   #  :data      =>   @data_output[block],
   #  :data_x    =>   ,
   #  :data_y    =>   ,
   #  :ldr       =>  string , #  -> @data_output[b][string.to_sym]
   #  :param     =>   ,
   #  :x1        =>  0 ,                   #window function
   #  :x2        =>  0 ,                   #window function
   #  :y1        =>  0 ,                   #window function
   #  :y2        =>  0 ,                   #window function
   #  :z         =>  0 ,                   #multidimensional extract &| ntuples
   #  :page      =>  0 ,                   #multidimensional extract &| ntuples
   #  }               
   end
   
   def output_ps(opt={})
     f_log "check option"
     if opt=={}
     opt= @option_hash[:output][:ps]  
     end
     puts "ps option"+opt.to_s
     ps = Postscript_output.new(opt)
     ps.build_ps
     file = @option_hash[:output_file] + ".ps"
     ofile=File.open(file, "w+")
     ofile.write(ps.output_text)
     f_log " in file: #{file} @ #{Time.now}"
     ofile.close
    
   end
   
   def output_cw(opt={})
     if opt=={}
     opt= @option_hash[:output][:cw]  
     end
     opt[:orientation] = 1
     b,p = opt[:block] ,opt[:page]
    # p = 
     opt[:data_y]||=@data_output[b][:raw_point][p][:y]
     opt[:resolution]=180
     ps =  Postscript_output.new(opt)
     ps.build_ps
     file = @option_hash[:file] 
     ofile=File.open(file, "w+")
     ofile.write(ps.output_text)
     f_log " in file: #{file} @ #{Time.now}"
     ofile.close
     f_log (" close file: #{file} ")

   end
   
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
   
   def find_data_block
     d=@data_output
     b=nil
     count=0
     #find first block with  data
     while count <= d.size
       b ||= count if d[count] && d[count][:raw_point] && d[count][:raw_point][0] && d[count][:raw_point][0][:y] != [] 
       count += 1
       end
     # line= "no xy plot data found"         if !b
     # line= "first  block with data : #{b}" if b
     # f_log line
     # puts line
     b
   end
   
  
  
    
   def ps_new
      ps = Postscript_output.new({:data => @data_output})
      ps.build_ps
      ps.output_text
   end
   
end