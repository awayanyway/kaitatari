##require 'ostruct'
require_relative  "pseudo_digit"
require_relative  "jdx_structure"


class Switchies
#todo multiblock and ntuple processing
#todo output =[block0,block1,....] block0=[headers], block1=[[Headers?], [params],[data=x,y | x,z,y,y,y..if ntuple]]
#output=[block0,block1,....] with block0 LDR up to new block (define by eitherblockid or already defined LDR or DATA table)
#data=[[indep][dep]]= [[T1,T2],[]
#todo process comment which are at the end of one LDR line 
#todo puts comment  somewhere else  (create class comment? or comment structure duplicated from headers? comment.TITLE )
#  todo  return unclassied ldr as a structure?

 
  include Data_structure
  include Pseudo_digit

  def initialize(  option={})
  temp=option[:process]
  ["headers","param","data","block"].each{ |opt|
            temp =~ /(opt)((?:\s*\w*)+)(?=(headers|param|data))/ 
            temp = $` + $' if $`
            option[:"mod_#{opt}"]=$1.to_s.gsub(/[^ \d]/," ").split(/\s+/ ) if $1 
            }
            
 
   #temp=option[:extract]
  
   @precision = (option[:precision].to_i != 0  && option[:precision].to_i) || nil

   # ground floor switch
   @g =   { :'case_1'  => -> {switch_1},    #match ldr     ##
            :'case_0'  => -> {switch_0},    #match comment $$
            :'Default' => -> {puts "g no match"if @v;@line=nil}
          }
    @h =@g

    # 1st floor switch : processing ldr
    @s1 = { :'case_11' => -> {switch_11},   #match LDR Regex_header
            :'case_12' => -> {switch_12},  #match LDR Regex_header_data
            :'case_13' => -> {switch_13},  #match LDR Regex_data
            :'case_14' => -> {switch_14},  #match LDR Regex_header_uncl
            :'case_0'  => -> {switch_0},
            :'Default' => -> {puts "s1 no match" if @v;@line=nil}
          }
    # 2nd floor switch  :  datapoints type
    @s2 = { :'case_21' => -> {switch_21}, #XYY
            :'case_22' => -> {switch_22}, #XY
            :'case_1'  => -> {puts "end of blocks/ntuple"; switch_exit},
            :'case_0'  => -> {switch_0},
            :'Default' => -> {puts "s2 no match" if @v ;@line=nil}
          }
    # 3rd floor switch  : processing datapoints
    @s31 = {:'case_31' => -> {switch_31},  #match/retrieve x =  +/- 1234.56e+/-123
            :'case_1'  => -> {puts "end of block/ntuple"; switch_block},
            :'case_0'  => -> {switch_0},
            :'Default' => -> {puts "s31 no match" if @v ;@line=nil}
          }
    @s32 = {:'case_32' => -> {switch_32},
            :'case_1'  => -> {puts "end of block/ntuple"; switch_block},
            :'case_0'  => -> {switch_0},
            :'Default' => -> {puts "s32 no match" if @v ;@line=nil}
          }
          
    @exit =  {
          :'Default' => -> {@line=nil}
          }
   #other instance variable def
    @block_count= -1
    reinitialize_instance_variable
    @output=[]
    @temp_current[:'BLOCK ID']=0
  end
    
    
  def reinitialize_instance_variable(temp_cur=1)
    
    @temp_h    = Block_headers.new
    @temp_h_da = Block_data.new
    @temp_h_un = {}
    #@temp_h_un = OpenStruct.new
    @temp_current = case temp_cur
    when 1 then @temp_h
    when 2 then @temp_h_da
    when 3 then @temp_h_da
    when 4 then @temp_h_un  
    end
    
    @ldr ||= 'DUMPED_COMMENT'
    
    @datapoint = []
    @datatype  = ""
    @temp_data = ["",""]
    @temp = ""
    @tempx = [nil,nil]
    @tempy = ""
    @symbol_ind = []
    @temp_delta = 1
    @block_count += 1
    puts @block_count
  end

  def sw(line)
    return "exit" if @h == @exit 
    @line=line.strip
    while @line.to_s != ""
      switch(@h)
    end
    
  end


  def data_str2arr(str="",factor=1,precision=8)
    cond = ->(f=1){ f != 0 && f != 1}
    data_arr=str.split(" ")
    if cond.call(factor) && precision !=8
       data_arr.map!{|x| x  = x.to_f
                     x *= factor  
                     x  = x.to_d(precision) 
                     x.to_f}
    elsif cond.call(factor) && precision ==8
          data_arr.map!{|x| x  = x.to_f
                     x *= factor
                     x.to_f}
    elsif precision ==8  && !cond.call(factor)
          data_arr.map!{|x| x  = x.to_f 
                     x  = x.to_d(precision) 
                     x.to_f}
    else  data_arr.map!{|x| x  = x.to_f }
    end 
  end

   def output
    block_output
    puts "blocks processed = #{@output.size.pred} (#{@block_count.pred}) : number of blocks = #{@output[0][0][:'BLOCKS'] if @output[0][0][:'BLOCKS']}   "
    if @output.size==2 && @output[1][1][0] == []
      @output[1]=@output[0]
    end
    @output
   end
   
  def block_output(o=nil)
    #prepare xy data points array from strings
    xy=Array.new(2)
    xy=xy.map.with_index{|e,i|  if @temp_data[i] != ""
                         data_str2arr(@temp_data[i],@temp_h_da.FACTOR.fetch(@symbol_ind[i+2].to_i).to_f,@precision)
                         end}
    #merge structure while removing empty field
    output_hash={}
    [@temp_h,@temp_h_un,@temp_h_da].each{|s| s.each_pair{|k,v| output_hash[k]=v if !v.nil?}}   
    @output << [output_hash,[@symbol_ind[0..1],xy]] 
    reinitialize_instance_variable(o)
   end
   
  ######## def cases

  def Default
    true
  end

  def case_0
    /^\s*($$)+\s*(.*)/ =~ @line
  end

  def case_1
    /^\s*##\s*(.*)/ =~ @line && @line=$1
  end

  def case_11
    (@line =~ Regex_headers && @ldr=$1) && @line=$'
  end

  def case_12
    (@line =~ Regex_data_header && @ldr=$1) && @line=$'
  end

  def case_13
    (@line =~ Regex_data && @ldr=$1) && @line=$'
  end

  def case_14
    (@line =~ Regex_header_uncl && @ldr=$1) && @line=$'
  end

  def case_21
    @mod == "xyy" 
  end

  def case_22
    @mod == "xyxy"    
  end
  
  def case_31
    (@line =~ Regex_xread && @temp=$1) && @line=$'
  end
 
  def case_32
    (@line =~ Regex_xyread && @temp=[$1,$2]) && @line=$'
  end
 
 
  #### def switches: process lines, lift to switch levels, change mood
  def switch_block
    block_output
    @h=@g
    
  end
  
  def switch_exit
    @h=@exit
  end
  
  def switch_0
    @temp_current[@ldr] << @line.rstrip   
    # puts "#{__method__} switch11: blank or comment writing (#{@line.rstrip.chomp}) in (#{@ldr})"  if @v_s 
  end

  def switch_1
    @h = @s1
  end

  def switch_11
    #puts "#{__method__}: known ldr writing (#{@line.rstrip.chomp}) in (#{@ldr})" if @v_s
    @temp_current = @temp_h
    block_output(1) if @temp_current[@ldr].to_s != ""
    @temp_current[@ldr] = @line.rstrip
    @line=""
    @h=@g
  end

  def switch_12
    #puts "#{__method__}: known param ldr writing (#{@line.rstrip.chomp}) in (#{@ldr.rstrip.chomp})"  if @v_s
    @temp_current = @temp_h_da
    block_output(2) if @temp_current[@ldr].to_s != ""
    @temp_current[@ldr] = @line.rstrip
    @line=""
    @h=@g
  end

  def switch_13
    #puts "#{__method__}: preparing for reading (#{@ldr}) of type (#{@line}) \n refactoring param   " if @v_s
    @temp_current = @temp_h_da
    block_output(3) if @temp_current[@ldr].to_s != ""
    @temp_current[@ldr] = @line.rstrip
    block_refactoring(@temp_current)
    @symbol_ind=regex_data_table(@temp_current,@ldr)   
    #puts "@symbol_ind is #{@symbol_ind}" 
    @mod=@symbol_ind.pop
    @h = @s2 
    puts @mod
    @tempx[1] = @temp_current.FIRST.fetch(@symbol_ind[0])
    @temp_delta= @temp_current.DELTA.fetch(@symbol_ind[0]).to_f / @temp_current.FACTOR.fetch(@symbol_ind[0]).to_f
    @line=""
    #@temp_current.each_pair{|k ,v| puts "#{k}#{" "*(20-k.size)}  =  #{v}"}  if @v_s
    #puts "symbol_ind #{@symbol_ind}"                                     if @v_s
    
  end

  def switch_14
    #puts "#{__method__}: unknown ldr writing (#{@line.rstrip.chomp}) in (#{@ldr.rstrip.chomp})"   if @v_s
    @temp_current = @temp_h_un
    block_output(4) if @temp_current[@ldr].to_s != ""
    @temp_current[@ldr] = @line.rstrip
    @line=nil
    @h=@g
  end
 
 
  ##maybe should match first is .a..(=)..b. then check if a known , instead of matching (a)..=.. then

  def switch_21
   # puts "#{__method__}:"
    
    @h=@s31
  end
  
  
  def switch_22
 # puts "#{__method__}:"
    
    @h=@s32

  end

  def switch_31
    #  puts "#{__method__}:"
    #todo in some file the first x of each dta line is rounded so might want to use FIRSTX and increment  only
    @tempy = line_yyy_translator(@line ) 
    lasty = @tempy.pop
    count = @tempy.pop
    # puts @tempy
    @temp_data[1]<< @tempy.pop
    lastx= @tempx[1]
    #xcheck(@temp, lastx)
    @tempx= xline_generator(@temp, count,@temp_delta )           
    @temp_data[0]  << @tempx[0]           
    @line=nil  
  end
  
  
  def switch_32
    #puts "#{__method__}:"
    @temp_data[1]<< "#{@temp.pop} "
    @temp_data[0]<< "#{@temp.pop} "
  end

  

  def m(arg) # (modify line or mod from outside and return object)
    #@line=arg if arg.is_a?(Array)
    @line = arg if arg.is_a?(String)
    @mod  = arg if arg.is_a?(Symbol)
    return self
  end

   
  
    
end