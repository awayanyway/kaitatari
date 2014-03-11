#!/usr/zbin/env ruby

require_relative "jdx_structure/jdx_structure_NMR"
require_relative "jdx_structure/jdx_structure_IR"


module Data_structure
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
    :'DATA TYPE',
    :'DATA CLASS',
    :'APPLICATION',
    :'ORIGIN',
    :'OWNER',
    :'DATE',
    :'LONGDATE',
    :'TIME',
    :'SPECTROMETER/DATA SYSTEM',
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
    :'FIRST',
    :'LAST',
    :'MIN',
    :'MAX',
    :'FACTOR',
    :'DELTA',   #private LDR
    :'END'
  ]

  Label_spectral_data_sym = [  #X++(Y..Y), X++(Y.Y), XY..XY  
    :'XYDATA',
    :'DATA TABLE',
    :'PEAK TABLE',
    :'XYPOINTS',
    :'PEAK ASSIGNMENT',
    
  ]
  
  
  Label_dump_sym = [
    :'DUMPED_COMMENT'
  ]

  Value_spectral_data = [
    ''
  ]
  Label_headers        = (Label_header_info_sym + Label_sample_info_sym).map {|s| s.to_s}
  Label_spectral_param = Label_spectral_param_sym.map{|s| s.to_s}
  Label_spectral_data  = Label_spectral_data_sym.map {|s| s.to_s}


  Regex_init        = Regexp.new(/^\s*#{Key_init}\s*/)                           # $' does not contain whitespace
  Regex_data_header = Regexp.new(/^(#{Label_spectral_param.join('|')})\s*=\s*/)  # lookahead  of whitespace(s) + '=':  (?=\s*=)
  Regex_data        = Regexp.new(/^(#{Label_spectral_data.join('|') })\s*=\s*/)
  Regex_headers     = Regexp.new(/^(#{Label_headers.join('|')       })\s*=\s*/)
  Regex_header_uncl = Regexp.new(/^(.*)=\s*/)
 
  Block_header  =   Struct.new(*(Label_header_info_sym ) )
  Block_sample  =   Struct.new(*(Label_sample_info_sym ) )
  Block_headers =   Struct.new(*(Label_header_info_sym + Label_sample_info_sym + Label_dump_sym) )
  #Block_unclas_ldr = OpenStruct.new
  Block_data    =   Struct.new(*(Label_spectral_param_sym + Label_spectral_data_sym + Label_dump_sym) )
  #Block_dump   =   Struct.new(*(Label_dump_sym ) )

 

  def regex_data_table(block,ldr)
    ## works only for two-symbols data type (XY but not XYZ) if needed the returned "ind" array
    # should be ind = [[X ,Y, Z],[0,1,2], xyz] meaning 
    #[[symbols list (string)],[corresponding index from SYMBOL (integer)], data type code for processing (string to match)]
    #ldr = :'XYDATA', :'DATA TABLE',  :'PEAK TABLE',    :'XYPOINTS'
    dim=block.SYMBOL.size
    ind=[]
    perm= block.SYMBOL.uniq.permutation(2).to_a
    #block.each_pair{|k ,v| puts "#{k}#{" "*(20-k.size)}  =  #{v}"} #if @v_refactoring
    while ind[0..1] == []
      #puts perm
      a=perm.pop  
      #puts "perm #{perm} \n a #{a}\n block.ldr #{block[ldr]}" # if @v_refactoring
      ##X++(Y..Y)
      if block[ldr] =~ /^\s*\(?(#{a[0]})\+{1,2}\((#{a[1]})\.{1,2}#{a[1]}\)/
         ind=[block.SYMBOL.index($1),block.SYMBOL.index($2),a[0],a[1],"xyy"]
      ##XY..XY
      elsif  block[ldr] =~ /^\s*\(?(?:(#{a[0]})(#{a[1]})\.{0,2}#{a[0]}#{a[1]}\)?\s*)/ #todo recheck this regexp
         ind=[block.SYMBOL.index($1),block.SYMBOL.index($2),a[0],a[1],"xyxy"]
      end
    end
    ind #return 
  end

  def block_refactoring(block)
    temp = ""
    size_dim = []
    #LDRs /^\s*\(?(#{a[0]})(#{a[1]})\.{0,2}(?:#{a[0]}#{a[1]})?+/ values to array
    ["SYMBOL","VAR_TYPE","VAR_FORM","VAR_DIM","UNITS","FIRST","LAST","MIN","MAX","FACTOR","DELTA"].each {|ldr|
      block[ldr]= record_to_a(block[ldr])
      size_dim << block[ldr].size
    }
    #XY TO SYMBOL  #NPOINTS to VARIABLE DIMENSION
    if size_dim[0] == 0
    block[:'SYMBOL'] << "X" if ["FIRSTX","LASTX","XUNITS", "XFACTOR", "DELTAX"   ].map{|ldr| block[ldr]}.join.gsub(/\s*/, "").size > 0
    block[:'SYMBOL'] << "Y" if ["FIRSTY","LASTY","YUNITS","MINY","MAXY"].map{|ldr| block[ldr]}.join.gsub(/\s*/, "").size > 0
    ["X","Y"].each{|i|   ["UNITS",          "FACTOR"].each{|ldr| block[ldr] << block[ldr.prepend(i)].to_s}
                 ["FIRST","LAST","MIN","MAX","DELTA"].each{|ldr| block[ldr] << block[ldr.concat(i)].to_s}  }
    size_dim[0]=block[:'SYMBOL'].size
    size_dim[0].times {block.VAR_DIM << temp} if (temp = block.NPOINTS.to_i.abs)  > 0
    end
    
    #calculate or copy DELTA
    #todo couple of DELTA calc test (now works with TEST.DX)   
    (size_dim[0]- size_dim.last).times{block.DELTA << ""}
    #puts "#{__method__} block.DELTA #{block[:DELTA]}"  if @v_refactoring
    block.DELTA = block.DELTA.map.with_index{|inc,i| (inc.to_f != 0 && inc)|| delta(block, i) } 
    #puts "#{__method__} block.DELTA #{block.DELTA}" if @v_refactoring
    #uncomment next line to force delta re-calculation
    #block.DELTA = block.DELTA.map.with_index{|inc,i|  delta(block, i )} 
    
  end

  def record_to_a(str)
    ## transform LDR value from string to /,/separated-array
    temp= str.to_s.split(/\s*,\s*/)
    temp[0]=temp[0].lstrip unless temp[0].nil?
    #   puts "in method:{__method__} ldr entry is #{str} \n to array = #{temp}"
    temp
  end

 def delta(block, symb="X")
    ## if last first and dim defined return (last-first)/(dim-1)
    s= (symb.is_a?(Integer) && symb) || block.SYMBOL.index(symb)
    #puts "#{__method__ } s = #{s} symb = #{symb}" if @v_delta
    temp = ["VAR_DIM","UNITS","FIRST","LAST"].map{|ldr| (s < block[ldr].size && block[ldr].fetch(s)) || nil}
    #puts "in method #{__method__ } temp = #{temp}" if @v_delta
    n= (temp[0].to_s =~  /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ && ($1.to_i - 1)) || nil
    l=  (temp[3].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
    f=  (temp[2].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
    #puts "in method #{__method__ } n = #{n} \n  l = #{l} \n f = #{f}" if @v_delta
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
