#!/usr/zbin/env ruby

require_relative "jdx_structure/jdx_structure_NMR"
require_relative "jdx_structure/jdx_structure_IR"
module Data_structure_ext
  include Data_structure_IR
  include Data_structure_NMR
end

module Data_structure
  include Data_structure_ext
  
  private
 # def verb(opt=nil)
 # #verbose
  # @v_delta= (opt =~ /delta/ && 0) || nil
  # @v_refactoring= (opt =~ /refac/ && 0) || nil
  # end   
  Key_init = '##'
  Key_comment = '$$'
  Key_end = [ 'END'
  ]

  ##  JCAMP-Defined Data Labels
  Label_header_info_sym = [
    :'TITLE',
    :'JCAMP-DX',
    :'JCAMPDX',
    :'DATA TYPE',
    :'DATA CLASS',
    :'APPLICATION',
    :'ORIGIN',
    :'OWNER',
    :'DATE',
    :'LONGDATE',
    :'TIME',
    :'SPECTROMETER/DATA SYSTEM',  ##todo fix this symbol matching ?? problem with "/" ??
    :'INSTRUMENT PARAMETERS',
    :'BLOCKS',
    :'BLOCK ID',
    :'AUDIT TRAIL'
  ]

  Label_sample_info_sym = [
    :'DATA PROCESSING',
    :'SAMPLE DESCRIPTION',
    :'SAMPLING PROCEDURE',
    :'PATHLENGTH',
    :'PRESSURE',
    :'TEMPERATURE',
    :'CAS NAME',
    :'NAMES',
    :'MOLFORM',
    :'CAS REGISTRY NO',
    :'WISWESSER',
    :'BEILSTEIN LAWSON NO',
    :'MP',
    :'BP',
    :'REFRACTIVE INDEX',
    :'DENSITY',
    :'MW',
    :'CONCENTRATIONS',
    :'STATE',
    :'CROSS REFERENCE'
  ]

  Label_spectral_param_sym = [
    :'XUNITS',
    :'YUNITS',
    :'XFACTOR',
    :'YFACTOR',
    :'DELTAX',
    :'DELTAY',
    :'RESOLUTION',
    :'NPOINTS',
    :'FIRSTX',
    :'FIRSTY',
    :'LASTX',
    :'LASTY',
    :'MAXX',
    :'MINX',
    :'MAXY',
    :'MINY',
    :'VAR_NAME',
    :'SYMBOL',
    :'VAR_TYPE',
    :'VAR_FORM',
    :'VAR_DIM',
    :'UNITS',
    :'kUNITS',  #kaitatari specific LDR
    :'FIRST',
    :'LAST',
    :'MIN',
    :'MAX',
    :'FACTOR',
    :'DELTA',   #kaitatari specific LDR
    #:'END'
  ]

  Label_spectral_data_sym = [  #X++(Y..Y), X++(Y.Y), XY..XY  
    :'PAGE',
    :'XYDATA',
    :'DATA TABLE',
    :'PEAK TABLE',
    :'XYPOINTS',
    :'PEAK ASSIGNMENT',
    :'END NTUPLES',
    :'FIRST'                 #
    
  ]
  
  Label_kaitatari_sym = [

    :'NPOINTS',
    :'VAR_NAME',
    :'SYMBOL',
    :'NSYMBOL',           #kaitatari specific LDR
    :'VAR_TYPE',
    :'VAR_FORM',
    :'VAR_DIM',
    :'UNITS',
    :'kUNITS',
    :'kFACTOR',            #kaitatari specific LDR
    :'FIRST',
    :'LAST',
    :'MIN',
    :'MAX',
    :'FACTOR',
    :'DELTA',             #kaitatari specific LDR 
    # :'PAGE',
    # :'XYDATA',
    # :'DATA TABLE',
    # :'PEAK TABLE',
    # :'XYPOINTS',
    # :'PEAK ASSIGNMENT',
    # :'END NTUPLES',
    
    # #below only kaitatari specific LDR
    :'kai_TITLE',   
    :'kai_DATA_TYPE',
    :'kai_DATA_CLASS',
    :'kai_BLOCK_ID',
    :'SYMBOL_INDEX',     
    :'data_FIRST',        
    :'x_reversed', 
    :'kai_indn',
    :'kai_indz'  ,      
    :'xcheck_count',
    :'ycheck_count',
    :'line_count',
    :'ldr_extract'
       
    
    
  ]
  
  
  Label_dump_sym = [
    :'DUMPED_COMMENT'   #kaitatari specific LDR
  ]

  # Value_spectral_data = [
    # ''
  # ]
  
  Label_headers        = (Label_header_info_sym + Label_sample_info_sym).map {|s| s.to_s}
  Label_header_info    = Label_header_info_sym.map {|s| s.to_s}
  Label_sample_info    = Label_sample_info_sym.map {|s| s.to_s}
  Label_spectral_param = Label_spectral_param_sym.map{|s| s.to_s}
  Label_spectral_data  = Label_spectral_data_sym.map {|s| s.to_s}
  Label_kaitatari      = Label_kaitatari_sym.map {|s| s.to_s}

  Regex_init           = Regexp.new(/^\s*#{Key_init}\s*/)                           # $' does not contain whitespace
  Regex_headers        = Regexp.new(/^(#{Label_headers.join('|')})/) #Regexp.new(/^(#{Label_headers.join('|')    })\s*=\s*/) 
  Regex_header         = Regexp.new(/^(#{Label_header_info.join('|')})/)#Regexp.new(/^(#{Label_header_info.join('|')})\s*=\s*/)
  Regex_sample_info    = Regexp.new(/^(#{Label_sample_info.join('|')})/)#Regexp.new(/^(#{Label_sample_info.join('|').gsub(/\//,".")})\s*=\s*/) 
  Regex_spectral_param = Regexp.new(/^(#{Label_spectral_param.join('|')})/)  #\s*=\s*# lookahead  of whitespace(s) + '=':  (?=\s*=)
  Regex_data           = Regexp.new(/^(#{Label_spectral_data.join('|') })/)  #\s*=\s*
  Regex_uncl_ldr       = Regexp.new(/^(\S+.*)=\s*/)
  
 
  Block_header   =  Struct.new(*(Label_header_info_sym ) )
  Block_info   =  Struct.new(*(Label_sample_info_sym ) )
  Block_param    =  Struct.new(*(Label_spectral_param_sym) )
  Block_headers  =  Struct.new(*(Label_header_info_sym    + Label_sample_info_sym   + Label_dump_sym) )
 # Block_data     =  Struct.new(*(Label_spectral_param_sym + Label_spectral_data_sym + Label_dump_sym) )
  Block_data     =  Struct.new(*(Label_spectral_data_sym) )
  Block_kaitatari=  Struct.new(*(Label_kaitatari_sym    + Label_dump_sym) )
  #Block_dump   =   Struct.new(*(Label_dump_sym ) )
  #Block_unclas_ldr = OpenStruct.new
 Block_point = Struct.new(:x,:y,:z,:n)
class Hua_point<Block_point
 def initialize
   Block_point.members.each{|m| self[m]=[]}
 end
 def xy
   self.x.zip(self.y)
 end

end

class Spectral_param<Block_param
  
  
end

  def regex_data_table(block,ldr)
    ## works only for two-symbols data type (XY but not XYZ) if needed the returned "ind" array
    # should be ind = [[X ,Y, Z],[0,1,2], xyz] meaning 
    #[[symbols list (string)],[corresponding index from SYMBOL (integer)], data type code for processing (string to match)]
    #ldr = :'XYDATA', :'DATA TABLE',  :'PEAK TABLE',    :'XYPOINTS'
    dim=block.SYMBOL.size
    ind=[]
    perm= block.SYMBOL.uniq.permutation(2).to_a
    #block.each_pair{|k ,v| f_log("#{k}#{" "*(20-k.size)}  =  #{v}")} #if @v_refactoring
    while ind[0..1] == []
      #f_log perm
      a=perm.pop  
      #f_log "perm #{perm} \n a #{a}\n block.ldr #{block[ldr]}" # if @v_refactoring
      ##X++(Y..Y)
      if block[ldr].last =~ /^\s*\(?(#{a[0]})\+{1,2}\((#{a[1]})\.{1,2}#{a[1]}\)/
        
        #if /^\s*\((?<x>\w+)\+{1,2}\((?<y>\w+)\.{1,2}\k<y>\)/ =~ block[ldr].last
        #
         ind=[block.SYMBOL.index($1),block.SYMBOL.index($2),a[0],a[1],"xyy"]
      ##XY..XY
      elsif  block[ldr] =~ /^\s*\(?(?:(#{a[0]})(#{a[1]})\.{0,2}#{a[0]}#{a[1]}\)?\s*)/ #todo recheck this regexp
         # /^\s*\(?(?:(?<x>\w+)(?<y>\w+)\.{0,2}\k<x>\k<y>\)?\s*)/
         ind=[block.SYMBOL.index($1),block.SYMBOL.index($2),a[0],a[1],"xyxy"]
      end
    end
    ind #return 
  end

  def block_refactoring(block)
    temp = ""
    size_dim = []
    block[:DUMPED_COMMENT]||=[]
    ["SYMBOL","VAR_TYPE","VAR_FORM","VAR_DIM","UNITS","FIRST","LAST","MIN","MAX","FACTOR","DELTA"].each {|ldr|
      #f_log " ldr  is #{ldr} "
       
     templdr = record_to_a(block[ldr]) 
     block[:DUMPED_COMMENT] << templdr[1]
     block[ldr]=templdr[0].flatten
     size_dim << block[ldr].size
     f_log "#{ldr} = #{block[ldr].size}"
    }
    #XY TO SYMBOL  #NPOINTS to VARIABLE DIMENSION
    if size_dim[0] == 0
       block[:'SYMBOL'] << "X" if ["FIRSTX","LASTX","XUNITS", "XFACTOR", "DELTAX"   ].map{|ldr| block[ldr]}.flatten.compact.join.gsub(/\s*/, "").size > 0
       block[:'SYMBOL'] << "Y" if ["FIRSTY","LASTY","YUNITS","MINY","MAXY"].map{|ldr| block[ldr]}.flatten.compact.join.gsub(/\s*/, "").size > 0
       ["X","Y"].each{|i|   ["UNITS",          "FACTOR"].each{|ldr| l="#{ldr}".prepend(i)
                                                                    a = (block[l] && block[l][0]) || ""
                                                                    block[ldr] << a}
                    ["FIRST","LAST","MIN","MAX","DELTA"].each{|ldr| l="#{ldr}".concat(i)
                                                                     a = (block[l] && block[l][0]) || ""
                                                                    block[ldr] << a}  }
       size_dim[0]=block[:'SYMBOL'].size
       block.VAR_DIM ||=[]
       if block.VAR_DIM.size < 1
           size_dim[0].times {block.VAR_DIM << temp} if (temp = block.NPOINTS[0].to_i.abs)  > 0
       end
    end
    
    ## calculate or copy DELTA (increment)
    ##todo couple of DELTA calc test (now works with TEST.DX)   
    (size_dim[0]- size_dim.last).times{block.DELTA << ""}
    block.DELTA = block.DELTA.map.with_index{|inc,i| (inc.to_f != 0 && inc)|| delta(block, i) } 
    #f_log " block.DELTA #{block.DELTA}" if @v_refactoring
    ##uncomment next line to force delta re-calculation
    #block.DELTA = block.DELTA.map.with_index{|inc,i|  delta(block, i )} 
    
    #make a copy of  UNITS
    block[:'kUNITS'] = block[:'UNITS'].dup
  end

  def record_to_a(str)
    temp_comment=[]
    str=[str] unless str.is_a?(Array)
    str=str.map{|e|   temp=e.to_s
                   if temp =~ /(?=\$\$)/        
                   temp_comment << $'.strip  if $' 
                   temp=($`.strip == "" && nil )|| $`.split(/\s*,\s*/).map{|x| x.strip if x}
                   else
                    temp = temp.split(/\s*,\s*/).map{|x| x.strip if x }
                   end
                   }       
      [str.flatten.compact,temp_comment] 
    
  end

 def delta(block, symb="X")
    ## calculate increment for the given symbol:
    ## if last first and dim are defined for the symbol, it returns (last-first)/(dim-1)
    s= (symb.is_a?(Integer) && symb) || block.SYMBOL.index(symb)
    f_log " s = #{s} symb = #{symb}" #if @v_delta
    temp = ["VAR_DIM","UNITS","FIRST","LAST"].map{|ldr| (s < block[ldr].size && block[ldr].fetch(s)) || nil}
    f_log " temp = #{temp}" #if @v_delta
    n= (temp[0].to_s =~  /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ && ($1.to_i - 1)) || nil
    l=  (temp[3].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
    f=  (temp[2].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
    f_log " n = #{n} \n  l = #{l} \n f = #{f}" #if @v_delta
    if n && n > 0
      if l
        if f && f != l
        block.DELTA[s] = (l-f)/n
        elsif l == n+1
        block.DELTA[s]=1
        end
      end
    else  block.DELTA[s]=1
    end
  end
 
end
