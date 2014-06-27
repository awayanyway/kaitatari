#require_relative "../jdx_structure/jdx_structure_NMR"
#require_relative "../jdx_structure/jdx_structure_IR"

module Sweetcheese_case
  include Data_structure
  include Pseudo_digit
  def Default
    true
  end

  def case_init_com
    /^\s*\$\$\s*(.*)/ =~ @line && @line='$$'+$1.rstrip
  end
  
  # def case_comment
    # /^\s*\$\$\s*(.*)/ =~ @line && @line=$1.rstrip
  # end

  def case_end
    @ldr =~ /^END\Z/
  end
  
  def case_init_ldr
    (/^\s*##\s*(\S.*?\S)\s*=/ =~ @line && (@ldr,@ldr_o= $1.sanitized_ldr.to_sym,$1.to_sym))  &&    @line=$'.strip## != ""
  end
  
  def case_multi_line
    @ldr   && @line.strip! != ""
    
    #@line && @line.strip! != ""
  end
  
  def case_extract
    #@ldr =~ @regex_spec_param
    /\|#{@ldr}\|/ =~ @regex_extract && @regex_extract=$`+"|"+$'
    #(@line =~ @regex_spec_param && @ldr=$1) && @line=$'
  end
  
   def case_general(key)
      @ldr =~ @block_current[key].sanitized_regexp
   end
    
  def case_header
    case_general(:header)
    #@ldr =~ Regex_header #  line != "" &&  @ldr =~ Regex_header
    #(@line =~ Regex_header && @ldr=$1) && @line=$'
  end

  def case_sample_info
    case_general(:info)
    #@ldr =~ Regex_sample_info 
    #(@line =~ Regex_sample_info && @ldr=$1) && @line=$'
  end

  def case_spec_param
   #  @ldr.to_s+(@block_current[:spec] && @block_current[:spec].true_member?(@ldr)).to_s
       @block_current[:spec] && @block_current[:spec].true_member?(@ldr)
  end
  
  def case_spectral_param
    case_general(:param)
    #@ldr =~ Regex_spectral_param
    #(@line =~ Regex_spectral_param && @ldr=$1) && @line=$'
  end
  
  def case_data
    case_general(:data)
    #@ldr =~ Regex_data
    #(@line =~ Regex_data && @ldr=$1) && @line=$'
  end

  def case_uncl_ldr
   
    true
    #(@line =~ Regex_uncl_ldr && @ldr=$1) && @line=$'
  end

 
  
  def case_31
    (@line =~ Regex_xread && @temp=$1) && @line=$'
  end
 
  def case_32
    (@line =~ Regex_xyread && @temp=[$1,$2]) && @line=$'
  end
 
end

module Sweetcheese_switch
  include Data_structure
  include Data_structure_NMR
  

  
  def switch_block
    #   block_output_data
    block_init
    @h=@s1
  end
  
  def switch_exit
    @h=@exit
  end
  
 
  def switch_multi_line
     @temp_current[@ldr]=@line 
     @extract[@ldr]   << @line  if @x_multi &&  @extract[@ldr]
    @line = nil
  end
 
  def switch_comment
    if @line != "" && @ldr
      @temp_current[@ldr]=@line
      @extract[@ldr]   <<   "$$"+@line.rstrip if @x_com && @extract[@ldr]
    end
    @line = nil
  end

  def switch_init_ldr
   
   @h = @s1
  end
  
   def switch_extract
    
    @block_current[:extract][@ldr.to_sym] = [@line.strip] if @line
    stop_it if @process[:extract_first] && @regex_extract == "|"
   end 
  
  def switch_base
    
    inc =nil
    if @temp_current ==  @block_current[:header] && @temp_current.fetch(@ldr,false)
     switch_check_spec 
     block_init(@ldr) 
    end
    inc=true          if @temp_current ==  @block_current[:uncl]   && @temp_current.fetch(@ldr,false)
    
    p=[@ldr_o,@line, inc].compact
    @line && (@temp_current.send(:[]=, *p)) && @line=nil
     
    @h=@g
  end
  
  def switch_check_spec
 
    @tt||=[]
    type   = @header.DATATYPE.to_s+@header.ORIGIN.to_s    #  if @header.DATATYPE
    origin = @header.ORIGIN.to_s   # if @header.ORIGIN
       
    data_type        = [ 'NMR'                                                   , 'IR'] #todo declare these as constant in respecive jdx_structure file
    manufacturer_type =[['bruker'                   ,'varian']                   , []]
    
   if type 
      data_type.each_with_index{|t,i| 
                       /(?<typ>#{t})/i  =~ type 
                 if  Regexp.last_match(:typ)
                   @tt<<t
                   if origin 
                    manufacturer_type[i].each_with_index{ |m,j| origin =~ /(#{m})/i     #todo small/capital letter regexp
                                          @tt << $1 if $1}  
                   end
                 end}
    end     
      # "specific param with"+@tt.to_s
      @block_current[:spec] = Label_specific_param.new( @tt.join(" "), @block_current[:spec])
  end
  
  def switch_header
    switch_base
  end 
  
  def switch_sample_info
    switch_base
  end
  
  def switch_spec_param
    switch_base
  end


  def switch_spectral_param
    switch_base
  end
   
  def switch_refact_param
    #block = @block_current
    param = @block_current[:param]
   # com   = @block_current[:comment][:DUMPED_COMMENT]
    kai   = @kai
    ldr_list = ["SYMBOL","VAR_TYPE","VAR_FORM","VAR_DIM","VAR_NAME","UNITS","FIRST","LAST","MIN","MAX","FACTOR","DELTA"]
    temp = ""
    size_dim = []
     ldr_list.each {|ldr| ldr=ldr.sanitized_ldr.to_sym
       
                         kai[ldr] = (param.fetch(ldr) && param.fetch(ldr))||[]
                         size_dim  << (kai[ldr] || []).compact.size
                         if ldr.to_s =~/(FACTOR|FIRST)/
       end
       }
    #XY TO SYMBOL  #NPOINTS to VARIABLE DIMENSION
    if size_dim[0] == 0
       kai[:'SYMBOL'] = "X" if ["FIRSTX","LASTX","XUNITS", "XFACTOR", "DELTAX"].map{|ldr| param[ldr] || nil}.flatten.compact.join.gsub(/\s*/, "").size > 0
       kai[:'SYMBOL'] = "Y" if ["FIRSTY","LASTY","YUNITS","MINY","MAXY"       ].map{|ldr| param[ldr] || nil}.flatten.compact.join.gsub(/\s*/, "").size > 0
       ["X","Y"].each{|i|   ["UNITS",          "FACTOR"].each{|ldr| l="#{ldr}".prepend(i)
                                                                    a = (param[l] && param[l]) || ""
                                                                   
                                                                    (kai[ldr] &&    kai[ldr] = a) ||  kai[ldr] = a}
                    ["FIRST","LAST","MIN","MAX","DELTA"].each{|ldr| l="#{ldr}".concat(i)
                                                                     a = (param[l] && param[l]) || ""
                                                                    
                                                                   (kai[ldr] &&    kai[ldr] = a) ||  kai[ldr] = a}  }
       size_dim[0]=kai[:'SYMBOL'].size
       kai.VAR_DIM ||=[]
       if kai.VAR_DIM.size < 1
           size_dim[0].times {kai.VAR_DIM << temp} if (temp = param.NPOINTS[0].to_i.abs)  > 0
       end
     end
    #DELTA
     
    ## 
     
    if param.FIRSTY && (f=param.FIRSTY[0].strip) != ""
      kai.data_FIRST ||= []
      kai.data_FIRST << f.to_f
    end
  end
  
  
  # def record_to_a(str)
    # temp_comment=[]
    # str=[str] unless str.is_a?(Array)
    # str=str.map{|e|   temp=e.to_s
                   # if temp =~ /(?=\$\$)/        
                   # temp_comment << $'.strip  if $' 
                   # temp=($`.strip == "" && nil )|| $`.split(/\s*,\s*/).map{|x| x.strip if x}
                   # else
                    # temp = temp.split(/\s*,\s*/).map{|x| x.strip if x }
                   # end
                   # }       
      # [str.flatten.compact,temp_comment] 
  # end
  
  # def switch_dump_comment(ldr=@ldr,line=@line)
    # if /^\s*\$\$\s*(.*)/ =~ line  
      # com=@block_current[:comment][:DUMPED_COMMENT]
      # com[ldr] ||= []
      # com[ldr]  += $1.strip if  $1.strip !=""
      # line = $`
    # end
  # end
  
   def switch_data_PAGE
      #todo match for symbol eg  ##PAGE= T1= 0.1144165E-03
      #@kai.SYMBOL ||=[]
      @ntuple +=1
      if    /\s*(#{@kai.SYMBOL.join('|')})(\s+|\s*=+)/ =~ @line ##todo check this matching
       sym=$1
       @line = $'
     
       @kai.SYMBOL.each_with_index{|e,i|  if e.to_s =~ /#{sym}/
                                              ##todo collect index of symbol
                                              (sym=="N" && @kai.kai_indn<< i && @kai.kai_indz<< nil) ||  (@kai.kai_indz<< i && @kai.kai_indn << nil)
                                                      
                                            end           }
        if /^=\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+][0-9]+)?)\s*/ =~ @line
   
         if sym =="N"
          @temp_n = $1.to_f
         else
          @temp_z = $1.to_f 
         end
         
         #@line = $'   
        end
      end
      @h = @g
  end
  
  def switch_data_FIRST
      #todo match for float, get index of symbol from and convert to.. assign to temp pointer
      @block_current[:kai].data_FIRST = @line.to_f
      
         
  end
 
 def switch_data_base(clas="nd")
      kai=@kai
      raw=@raw
      
      raw << Hua_point.new
      raw.last.n << @temp_n if @temp_n
      raw.last.z << @temp_z if @temp_z
      @temp_n,@temp_z,@totalx=nil,nil,0
      
      ###
      symbol_index=switch_symbol
      kai.SYMBOL_INDEX ||= []
      kai.SYMBOL_INDEX << symbol_index
      
     
      ###
      x_index = symbol_index[0]
      if x_index
        @x_rev = switch_x_reversed(x_index)
         if kai.FACTOR[x_index] && kai.FACTOR[x_index].to_f != 0 && kai.FIRST[x_index]
            @lastx = kai.FIRST[x_index].to_f / kai.FACTOR[x_index].to_f 
            puts "first x = "+@raw.last.x.inspect
         end
      end
      
      ###
      
      if kai.data_FIRST.size == @ntuple.pred
       y_index = symbol_index[1]
       kai.data_FIRST << kai.FIRST[y_index].to_f        
      end
      
      kai.kai_DATA_CLASS<<clas
      kai.kai_DATA_TYPE<<@line
      
      
      ###
      kai.xcheck_count ||=[]
      kai.ycheck_count ||=[]
      if @lastx
         kai.xcheck_count +=[0,0]
      else
         kai.xcheck_count +=[0,-1]
      end
      kai.ycheck_count +=[0,0]
      @check=true
      mod=(@proc && symbol_index.last) || "no"
      @raw.last.y << kai.data_FIRST.last if mod=="xyy"
      switch_mod(mod)
      
   
 end
 
    def switch_data_XYDATA
  
      @check2 = true
      kai=@kai
      kai.kai_DATA_CLASS<<"XYDATA"
      raw=@raw
      raw << Hua_point.new
      raw.last.n << @temp_n if @temp_n
      raw.last.z << @temp_z if @temp_z
      
      @temp_n,@temp_z,@totalx=nil,nil,0
      
      ###
      symbol_index=switch_symbol
      kai.SYMBOL_INDEX ||= []
      kai.SYMBOL_INDEX << symbol_index
      ###
      x_index = symbol_index[0]
      if x_index
         @x_rev=switch_x_reversed(x_index)
          if kai.FACTOR[x_index] && kai.FACTOR[x_index].to_f != 0 && kai.FIRST[x_index]
            @lastx = kai.FIRST[x_index].to_f / kai.FACTOR[x_index].to_f 
            puts "first x = "+@lastx.inspect
         end
         if kai.DELTA[x_index].to_f == 0
           kai.DELTA[x_index] = (kai.LAST[x_index].to_f-kai.FIRST[x_index].to_f)/(kai.VAR_DIM[x_index].to_f-1)
         end
         @temp_delta= kai.DELTA[x_index].to_f / kai.FACTOR[x_index].to_f
    
      end
          
      ###
      
      if kai.data_FIRST.size == @ntuple.pred
       y_index = symbol_index[1]
       kai.data_FIRST << (kai.FACTOR[y_index] && kai.FIRST[y_index].to_f/ kai.FACTOR[y_index].to_f) || kai.FIRST[y_index].to_f        
      end
      
      kai.kai_DATA_TYPE<<@line
      
      # if kai.FACTOR[x_index] && kai.FACTOR[x_index].to_f != 0
      # @raw.last.x << kai.FIRST[x_index].to_f / kai.FACTOR[x_index].to_f 
      # end
      ###
      kai.xcheck_count ||=[]
      kai.ycheck_count ||=[]
      if @lastx
         kai.xcheck_count +=[0,0]
      else
         kai.xcheck_count +=[0,-1]
      end
      kai.ycheck_count +=[0,0]
      @check=true
      mod=(@proc && symbol_index.last) || "no"
      @raw.last.y << kai.data_FIRST.last if mod=="xyy"
      switch_mod(mod)
    end # of switch_data_XYDATA
    
    def switch_data_DATATABLE
      switch_data_XYDATA
    end
    
    def switch_data_PEAKTABLE
       switch_data_base("PEAKTABLE")
    end
    
    def switch_data_XYPOINTS
      switch_data_XYDATA
    end
    
    def switch_data_PEAKASSIGNMENTS
      switch_data_PEAKASSIGNMENT
     
    end
    
    def switch_data_PEAKASSIGNMENT
      
      switch_data_base("PEAKTABLE")
      @h=@g ##todo
    end
    
    def switch_data_ENDNTUPLES
      @h = @g
      stop_it if @process[:point] =~ /first_n/
      ## if @process[:data]=~ /yes/i
        ##todo 
      ##end
     
    end
    
    
    def switch_mod(mod)
       puts 'point type :'+mod.inspect
      @h = case mod
        when "xyy"  then  @s31
        when "xyxy" then  @s32
     #   when "xyma" then  @s33 #todo xyma
        when "no"   then  @s30
          
      end
     
    end
    
    def switch_x_reversed(i)
      kai=@kai
      param=@kai
    
      if !i
      i=kai.SYMBOL_INDEX.last[0]
      end
     
      (i && @kai[:x_reversed] = (param.FIRST[i] > param.LAST[i]))|| nil
          
    end
    
  def switch_data
    param=@kai
    param.kai_DATA_TYPE||=[]
    param.kai_DATA_CLASS||=[]
    
    param.data_FIRST||=[]
    param.kai_indz||=[]
    param.kai_indn||=[]
    @check2 = false
    #switch_dump_comment
    send("switch_data_"+@ldr.to_s) 
    @line && (@temp_current[@ldr] = @line) && @line=nil 
     
    #info_line ="" ;@temp_current.each_pair{|k ,v| info_line << k.inspect+" "*(20-k.size)+"  =  "+v.inspect}
  end
  
  def switch_symbol(block=@temp_current,ldr='XYDATA',str=@line,symbol=@block_current[:param].SYMBOL)
    
    symbol = ['X','Y'] if !symbol.is_a?(Array)
    symbol +=['X','Y'] if symbol.compact.size < 2
    
    #ldr = :'XYDATA', :'DATA TABLE',  :'PEAK TABLE',    :'XYPOINTS'
    # param=@block_current[:kai] #param]
    # data =@block_current[:kai] #data]
    #dim=symbol.size
    ind=[]
    perm= symbol.compact.uniq.permutation(2).to_a
    
    while ind[0..1] == []
      a=perm.pop 
      ##X++(Y..Y) 
      if str =~ /^\s*\(?(#{a[0]})\+{1,2}\((#{a[1]})\.{1,2}#{a[1]}\)/
        #str ~ param[ldr].last
        #if /^\s*\((?<x>\w+)\+{1,2}\((?<y>\w+)\.{1,2}\k<y>\)/ =~ param[ldr].last
         ind=[symbol.index($1),symbol.index($2),a[0],a[1],"xyy"]
       ##XY..XY
      elsif  str =~ /^\s*\(?(?:(#{a[0]})(#{a[1]})\.{0,2}#{a[0]}#{a[1]}\)?\s*)/ #todo recheck this regexp
         # /^\s*\(?(?:(?<x>\w+)(?<y>\w+)\.{0,2}\k<x>\k<y>\)?\s*)/
         ind=[symbol.index($1),symbol.index($2),a[0],a[1],"xyxy"]
      end
    end
    ind  
  end
  
  def switch_uncl_ldr
   # @ldr=@ldr.to_sym
    switch_base
  end
 

 

  def switch_31
    #todo in some file the first x of each dta line is rounded so might want to use FIRSTX and increment  only
    
   
   
    
    if @check
    firsty=@raw.last.y.last.to_f
    @raw.last.y.pop
    @kai.ycheck_count[-1] +=1
    end
   
    check=@check
    tempy,count,@check = *line_yyy_translator(@line) 
    count -=1 if @check
     
     @temp=@temp.to_f
    x=@temp#-@temp_delta
     d= @temp-@lastx
    if count >1
     @kai.xcheck_count[-1] +=1
   
     if (checkpoint(x,@lastx))
        @kai.xcheck_count[-2] +=1 
     elsif  (!@x_rev && (d/@temp_delta.abs <0.1) )
       # @temp=@lastx   
     end
    end
    @raw.last.y +=  tempy
    @raw.last.x += xline_generator(@temp, count,@temp_delta )
    @lastx=@temp + @temp_delta*count # @raw.last.x.last
    @totalx += count 
    @kai.ycheck_count[-2] +=1 if check && checkpoint(firsty,tempy[0],"y")        
    @line=nil  
  end
  
  
  def switch_32
    @raw.last.y << @temp.pop.to_f 
   @totalx +=1
    @raw.last.x << @temp.pop.to_f 
   
  end
  
  def switch_check_out
     process_data if @proc =~ /yes/i
     @kai.ldr_extract=@extract.keys
     @kai.ldr_extract.uniq! if @kai.ldr_extract
     stop_it if @process[:point].to_s =~ /first_page/
     pn = @raw[-1].n[-1]
     px = @totalx #@raw[-1].x.size
     py = @raw[-1].y.size
     pz = (@raw[-1].z.size < 2 && @raw[-1].z[-1]) || @raw[-1].z.size
     cx  = @kai.xcheck_count[-2..-1]
     cy  = @kai.ycheck_count[-2..-1]
     ix = @kai.SYMBOL_INDEX[-1][0]
     iy = @kai.SYMBOL_INDEX[-1][1]
     #iz = @kai.SYMBOL_INDEX[-1][1] if
     dx = @kai.VAR_DIM[ix].to_i
     dy = @kai.VAR_DIM[iy].to_i
     #dz = @kai.VAR_DIM[iz] if 
     sx = @kai.SYMBOL[ix]
     sy = @kai.SYMBOL[iy]
     #sz  = @kai.SYMBOL[iz] if
     line="\n_______checkpoint______"
     line << "\nnumb of pts (processed/expected): <#{sx}:#{px}/#{dx}}> - <#{sy}: #{py}/#{dy}>"
     if dx==px && dy==py && px==py    
       line << "\nsweet as"
     else 
       line << "\nmmmm... not good"
     end
    if @check2
     line << "\npoint checks (good/total):        <#{sx}:#{cx[-2]}/#{cx[-1]}> - <#{sy}: #{cy[-2]}/#{cy[-1]}"
     if cx[-2]==cx[-1] && cy[-2]==cy[-1]   
        line << "\nsweet as"
     else 
        line << "\nmmmm... not good"
     end
     end
        line << "\n____exit_checkpoint____"
     @lastx=nil
     puts line  
    
  end
  
end