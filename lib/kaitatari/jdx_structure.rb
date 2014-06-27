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
  
  Label_headers_s        = (Label_header_info_sym + Label_sample_info_sym).map {|s| s.to_s}
  Label_header_info_s    = Label_header_info_sym.map {|s| s.to_s}
  Label_sample_info_s    = Label_sample_info_sym.map {|s| s.to_s}
  Label_spectral_param_s = Label_spectral_param_sym.map{|s| s.to_s}
  Label_spectral_data_s  = Label_spectral_data_sym.map {|s| s.to_s}
  Label_kaitatari_s      = Label_kaitatari_sym.map {|s| s.to_s}



  Regex_init           = Regexp.new(/^\s*#{Key_init}\s*/)                           # $' does not contain whitespace
  Regex_headers        = Regexp.new(/^(#{Label_headers_s.join('|')})/) #Regexp.new(/^(#{Label_headers.join('|')    })\s*=\s*/) 
  Regex_header         = Regexp.new(/^(#{Label_header_info_s.join('|')})/)#Regexp.new(/^(#{Label_header_info.join('|')})\s*=\s*/)
  Regex_sample_info    = Regexp.new(/^(#{Label_sample_info_s.join('|')})/)#Regexp.new(/^(#{Label_sample_info.join('|').gsub(/\//,".")})\s*=\s*/) 
  Regex_spectral_param = Regexp.new(/^(#{Label_spectral_param_s.join('|')})/)  #\s*=\s*# lookahead  of whitespace(s) + '=':  (?=\s*=)
  Regex_data           = Regexp.new(/^(#{Label_spectral_data_s.join('|') })/)  #\s*=\s*
  Regex_uncl_ldr       = Regexp.new(/^(\S+.*)=\s*/)
  
 
  Label_header_info_struct    =  Struct.new(*(Label_header_info_sym ) )
  Label_sample_info_struct    =  Struct.new(*(Label_sample_info_sym ) )
  Label_spectral_param_struct =  Struct.new(*(Label_spectral_param_sym) )
  Label_headers_struct        =  Struct.new(*(Label_header_info_sym    + Label_sample_info_sym   + Label_dump_sym) )
 # Label_spectral_data_struct     =  Struct.new(*(Label_spectral_param_sym + Label_spectral_data_sym + Label_dump_sym) )
  Label_spectral_data_struct  =  Struct.new(*(Label_spectral_data_sym) )
  Label_kaitatari_struct      =  Struct.new(*(Label_kaitatari_sym    + Label_dump_sym) )
  #Block_dump   =   Struct.new(*(Label_dump_sym ) )
  #Block_unclas_ldr = OpenStruct.new
  
  Label_header_info    =  Struct.new(*(Label_header_info_sym ) )#{init_struct}
  Label_sample_info    =  Struct.new(*(Label_sample_info_sym ) )#{init_struct}
  Label_spectral_param =  Struct.new(*(Label_spectral_param_sym) )#{init_struct}
  Label_headers        =  Struct.new(*(Label_header_info_sym    + Label_sample_info_sym   + Label_dump_sym) )
 # Label_spectral_data_struct     =  Struct.new(*(Label_spectral_param_sym + Label_spectral_data_sym + Label_dump_sym) )
  Label_spectral_data  =  Struct.new(*(Label_spectral_data_sym) )#{init_struct}
  Label_kaitatari      =  Struct.new(*(Label_kaitatari_sym    + Label_dump_sym) )#{init_struct}
  
  
  class Label_specific_param
   include Data_structure_ext
   attr_reader :sanitized_members, :keys, :members,:truename,:comment
   
   
   def initialize(type,h=nil)
     @all=[]
     # "initialize specific param with \n"+type.to_s+"\n--------------"
     if type  =~ /NMR/i
        @all<<Label_spectral_param_NMR.new
     end
      if type  =~ /Bruker/i
        @all<<Label_bruker_NMR_spec_param.new
     end
       @members=[]
       @sanitized_members=[]
       @truename=[]
       @alias_table=[]
       @all.each{|s|  @members += s.members
                      @sanitized_members += s.sanitized_members
                      }
       @truename=Hash[@sanitized_members.zip(self.members)]               
       @keys =@members
       
       h && @members.each{|ldr| v=h.fetch(ldr,false);  v && self.olde(ldr,v)}
       #@comment=Comment.new
       
    end
    
    def [](k)
      @all.each{|s| 
                    return s[k] if s.true_member?(k) 
                   }
      nil               
    end
   
    def olde(key,val)
       @all.each{|s| 
                  return   s.olde(key,val)  if s.true_member?(key)  
          #            end 
                   }
      nil
    end
    def []=(key, val)
          
       @all.each{|s| 
                    if s.true_member?(key)
                      return s.send(:[]=,key,val) 
                    end 
                   }
      nil
        end
    
    def true_member?(k)
      @all.each{|s| r=s.true_member?(k)
                    return r if r  
                   }
      false              
    end
    
    
    def fetch(k,ret=nil,range=0..-1)
         @all.each{|s| if s.true_member?(k)
                    return s.fetch(k,ret,range) 
                    end 
                   }
         ret
        
    end
  end
  
 Hua_point = Struct.new(:x,:y,:z,:n)
 class Label_extract < Hash
   
 end
 
 class Label_uncl < Hash
   
 end
 class Comment < Hash
   
 end
class Hua_point #<Block_point
 
 def initialize
   
   Hua_point.members.each{|m|   
                                 #self.send(m.to_s.concat("=").to_sym,[])
                                  self[m]=[]
                                  }
 end
 
 def xy
   self.x.zip(self.y)
 end

end
#
[Label_header_info,Label_sample_info,Label_spectral_param,Label_spectral_data,Label_kaitatari,Label_uncl,Label_extract,Comment].each{|clas| 
  Object::meta_build(clas)
}

class Label_header_info #<Label_header_info_struct                            
end #of Header_info class


class Label_sample_info #<Label_sample_info_struct
end #of Sample_info class

class Label_spectral_param #<Label_spectral_param_struct  
   def []=(key, val)
       k=true_member?(key)
      
       
       if k 
        if val.is_a?(String) && val =~ /(\$\$)/        
           @comment[k] = [$'.strip]  if $'
           val=$`
        end      
        return if val == ""      
        if k == :SYMBOL
          
          l=0
          val.is_a?(String) && v=val.split(/\s*,\s*/).map{|x|  if x 
                                                                  r=x.strip 
                                                                  l=[l, x.to_s.length].max 
                                                                  r
                                                               end }  
          l<5 && l>0 && self.olde(k,v)
       
        elsif k == :VAR_TYPE
          val.is_a?(String) && v=val.split(/\s*,\s*/).map{|x|  if x 
                                                                  r=x.strip
                                                                 ( r!="" && r  =~ /^(INDEPENDENT|DEPENDENT|PAGE)\Z/ && r) || nil
                                                                  
                                                               end }  
             v.compact != [] && self.olde(k,v) 
        else   
      
          val.is_a?(String) && v=val.split(/\s*,\s*/).map{|x|  if x 
                                                                  r=x.strip 
                                                                  
                                                                  r
                                                               end }                                                   
          self.olde(k,v)
        end
        
        
       
       end
      end                           
end #of Spectral_param class
  
class Label_spectral_data #<Label_spectral_data_struct                               
end #of Spectral_param class

class Label_kaitatari
     def []=(key, val)
       return if !val
       k=true_member?(key)
       v=self.old(k)
       val=(!v.nil? && [v].flatten+[val].flatten) ||[val].flatten      
       #v=self.fetch(k,[])      
       #val= (val.is_a?(String) && val.strip)|| val
       #(!inc && v[-1] += val) || (inc && v += [val] )                         
       self.olde(k,val)
      end  
      def [](key)
       k=true_member?(key)
       (k && self.old(k)) || nil 
      end
end # class Label_kaitatari



 

  

 

 def delta(block, symb="X")
    ## calculate increment for the given symbol:
    ## if last first and dim are defined for the symbol, it returns (last-first)/(dim-1)
    s= (symb.is_a?(Integer) && symb) || block.SYMBOL.index(symb)
    temp = ["VAR_DIM","UNITS","FIRST","LAST"].map{|ldr| (s < block[ldr].size && block[ldr].fetch(s)) || nil}
    n= (temp[0].to_s =~  /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ && ($1.to_i - 1)) || nil
    l=  (temp[3].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
    f=  (temp[2].to_s =~ /^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+]?[0-9]+)?)\s*/ &&  $1.to_f) || nil
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
