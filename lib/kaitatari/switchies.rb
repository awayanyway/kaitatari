##require 'ostruct'
require_relative  "pseudo_digit"
require_relative  "jdx_structure"


class Switchies

  attr_accessor :line
  attr_reader :datapoint, :jdx

  include Data_structure
  include Pseudo_digit
  
  
  def initialize( *option)
  
  # unless option == []
   # option=option.to_s
   # #### Verbose
  # @v_c= (option =~ /verbose.*(case),?\s*/ && $1)  || nil 
  # @v_s=  (option =~ /verbose.*(switch),?\s*/ && $1)  || nil 
  # @v=(option =~ /(verbose)/ && $1)  || nil
  # @process= (option =~ /.*(switch),?\s*/ && $1)  || nil
  # end
  # ####
  
    @line=line
    @mod=""
    # ground floor switch
    @g =  {:'case_1' => -> {switch_1},
             :'case_0' => -> {switch_0},
          :'Default' => -> {puts "g no match"if @v;@line=nil}
          }
    @h =@g

    # 1st floor switch : processing ldr
    @s1= {:'case_11' => -> {switch_11},
           :'case_12' => -> {switch_12},
           :'case_13' => -> {switch_13},
           :'case_14' => -> {switch_14},
           :'case_0' => -> {switch_0},
           :'Default' => -> {puts "s1 no match" if @v;@line=nil}}
 # 2nd floor switch  :  datapoints type
    @s2 =    {:'case_21' => -> {switch_21}, #XYY
              :'case_22' => -> {switch_22}, #XY
              :'case_1' => -> {puts "end of first block/ntuple,to be continued"; switch_exit},
              :'case_0' => -> {switch_0},
              :'Default' => -> {puts "s2 no match" if @v ;@line=nil}
          }
    # 3rd floor switch  : processing datapoints
    @s3 =  {:'case_31' => -> {switch_31},
              :'case_32' => -> {switch_32},
              :'case_1' => -> {puts "end of first block/ntuple,to be continued"; switch_exit},
              :'case_0' => -> {switch_0},
              :'Default' => -> {puts "s2 no match" if @v ;@line=nil}
          }
          
 @exit =  {
          :'Default' => -> {@line=nil}
          }
    @datapoint=[]
    @datatype=""
    @temp_h    = Block_headers.new
    @temp_current = @temp_h
    #@temp_h_un = OpenStruct.new
    @temp_h_un = {}
    @temp_h_da = Block_data.new
    @temp_data = ["",""]
    @ldr = 'DUMPED_COMMENT'
    @temp =""
    @tempx =""
    @tempy =""
    @symbol_ind=[]
    @temp_delta=1
  end

  def sw(line)
    @line=line.strip
     #puts "line is (#{@line}) \n size is (#{@line.size})" if @v
   
    while @line.to_s != ""
      switch(@h)
    end
   
  end

def output
    cond = ->(f=1){ f != 0 && f != 1}
    x=@symbol_ind[2].to_i
    y=@symbol_ind[3].to_i
    factor = @temp_h_da.FACTOR.fetch(x).to_f
    # puts "factor 0 = #{factor}"  if @v
    x_arr = @temp_data[0].split(" ")
    x_arr.map!{|x| x.to_f * factor} if  cond.call(factor)
    #puts "x arr = #{x_arr}"
    factor = @temp_h_da.FACTOR.fetch(y).to_f 
    #puts "factor 1 = #{factor}"  if @v 
    y_arr = @temp_data[1].split(" ")
    y_arr.map!{|x| x.to_f * factor} if cond.call(factor)
    #puts "y arr = #{y_arr}"  if @v
    [@temp_h,@temp_h_un, @temp_h_da, *@symbol_ind,x_arr,y_arr]
end
  ######## def cases

  def Default
    true
  end

  def case_0
    puts "#{__method__}  comment line or multilines ldr  #{/^\s*($$)+\s*(.*)/ =~ @line && $1}" if @v_c
    ## LDR match ##__method__ == @mod && @line =~ Regex_init
    /^\s*($$)+\s*(.*)/ =~ @line
  end

  def case_1
    puts __method__ if @v_c
    ## LDR match ##__method__ == @mod && @line =~ Regex_init
    /^\s*##\s*(.*)/ =~ @line && @line=$1
  end

  def case_11
    puts "#{__method__} ldr is #{@line =~ Regex_headers && $1 }" if @v_c
    (@line =~ Regex_headers && @ldr=$1) && @line=$'
  end

  def case_12
    #LDR data param match
    puts "#{__method__} ldr is #{@line =~ Regex_data_header && $1}" if @v_c
    (@line =~ Regex_data_header && @ldr=$1) && @line=$'
  end

  def case_13
    #LDR data param table type
    puts "#{__method__} data param ldr is #{@line =~ Regex_data && $1}" if @v_c
    (@line =~ Regex_data && @ldr=$1) && @line=$'
  end

  def case_14
    #unclassified LDR 
    puts "#{__method__} unknown ldr  #{@line =~ Regex_header_uncl && $1}" if @v_c
    (@line =~ Regex_header_uncl && @ldr=$1) && @line=$'
  end


 def case_21
    # xyy
    puts " #{__method__}  h is #{@h.to_s} #{@line} "  if @v_c
    @mod =~ /^\s*xyy/ 
  end

 def case_22
    # xy
    puts " #{__method__}  is #{@line}"  if @v_c
    (@mod =~ /^\s*xyxy\s+/ )  #todo check regexp 
  end
  

 def case_31
    # read x +/- 1234.56e+/-123
    #puts " #{__method__} float is #{@line =~ Regex_xread && $1}"  if @v_c
    (@line =~ Regex_xread && @temp=$1) && @line=$'
  end
 
  def case_32
    # read y pseudodigit 
    #puts " #{__method__} float is #{@line =~ Regex_yread && $1}"  if @v_c
    (@line =~ Regex_yread && @temp=$1) && @line=$'
  end
 
 
  #### def switches: process lines, lift to switch levels, change mood

def switch_exit
  @h=@exit
end
  def switch_0
    @temp_current[@ldr] << @line.rstrip   
    # puts "#{__method__} switch11: blank or comment writing (#{@line.rstrip.chomp}) in (#{@ldr})"  if @v_s 
  end

  def switch_1
    @h = @s1
    #puts "#{__method__} now line is (#{@line.rstrip.chomp}) " if @v_s
   
  end

  def switch_11
    #puts "#{__method__}: known ldr writing (#{@line.rstrip.chomp}) in (#{@ldr})" if @v_s
    @temp_current = @temp_h
    @temp_current[@ldr] = @line.rstrip
    @line=""
    @h=@g
  end

  def switch_12
    
    #puts "#{__method__}: known param ldr writing (#{@line.rstrip.chomp}) in (#{@ldr.rstrip.chomp})"  if @v_s
    @temp_current = @temp_h_da
    @temp_current[@ldr] = @line.rstrip
    @line=""
    @h=@g
  end

  def switch_13

    #puts "#{__method__}: preparing for reading (#{@ldr}) of type (#{@line}) \n refactoring param   " if @v_s
    @temp_current = @temp_h_da
    @temp_current[@ldr] = @line.rstrip
    block_refactoring(@temp_current)
   
    @symbol_ind=regex_data_table(@temp_current,@ldr)   
     @mod=@symbol_ind.pop
     
      @temp_current.each_pair{|k ,v| puts "#{k}#{" "*(20-k.size)}  =  #{v}"}  if @v_s
       puts "symbol_ind #{@symbol_ind}"                                     if @v_s
        
   
    @h=@s2
  end

  def switch_14
   # puts "#{__method__}: unknown ldr writing (#{@line.rstrip.chomp}) in (#{@ldr.rstrip.chomp})"   if @v_s
    @temp_current = @temp_h_un
    @temp_current[@ldr] = @line.rstrip
    puts " #{@temp_current.to_s} " if @v_s
    # = @line.rstrip
    @line=nil
    @h=@g
 
  end
  ##maybe should match first is .a..(=)..b. then check if a known , instead of matching (a)..=.. then

def switch_31
  #  puts "#{__method__}:"
    #todo check firstx comes here
     @tempy = line_yyy_translator(@line ) 
                lasty = @tempy.pop
                count = @tempy.pop
               # puts @tempy
     @temp_data[1]<<     @tempy.pop
    
    @tempx= xline_generator(@temp, count,@temp_delta )
                lastx= @tempx.pop
                 xcheck(@temp, lastx)
                
     @temp_data[0]        << @tempx.pop
                
                
      @line=nil
         #       xcheck(firstx, lastx) 
  end
  
  
  def switch_32
 #puts "#{__method__}:"
    
  end

  def switch_21
   # puts "#{__method__}:"
    #todo init firstx comes here
      @tempx = @temp_current.FIRST.fetch(@symbol_ind[0])
      @temp_delta=@temp_current.DELTA.fetch(0)
      @line=""
      @h=@s3
  end
  
  
  def switch_22
 # puts "#{__method__}:"

  end


  def m(arg) # (modify line or mod from outside and return object)
    #@line=arg if arg.is_a?(Array)
    @line=arg if arg.is_a?(String)
    @mod=arg if arg.is_a?(Symbol)
    return self
  end

   
  # end

end

# def case_comm
# ##  __method__ == @mod && @line =~ /^\s*($$)/
# ## Label_comment or blank
# end

# def si
# __method__ == @mod &&   @line =~ /^\s*\w/
# ## Label_sample_info_sym
# end
# def sp
# __method__ == @mod    ##Label_spectral_param
# end
# def sdp
# ##Label_spectral_data
# end
