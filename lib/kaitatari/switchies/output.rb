require_relative "../core_ext"
require 'json'

module Sweet_output
 include Data_structure
 include Pseudo_digit
 
 LDR =[:header,:info,:spec,:uncl,:param,:data,:extract,:kai] 

# def prep_p(*p)
 # if p && p.respond_to(:to_a)
  # p=p.to_a.flatten.map{|e| (e.respond_to?(:to_sym) && e.to_sym) || nil}.compact 
  # p=LDR-p
  # p=LDR-p
  # else
   # p=LDR
  # end
  # # p+=[:raw_point,:processed_point,:comment]
  # p
# end

def get_ldr_cat(*p)

end

class Turutu<Hash
include Data_structure
include Pseudo_digit
  
def initialize(process={})
  h= {
    #:header          => Label_header_info.new ,
    #:info            => Label_sample_info.new ,
    #:param           => Label_spectral_param.new ,
    #:data            => Label_spectral_data.new ,
    #:uncl            => {} ,
    :kai             => Label_kaitatari.new ,
    :extract         => Label_extract.new,  
    :raw_point       => [] ,
    :processed_point => [] ,
    :flotr2_point =>[],
    #:comment         => {:DUMPED_COMMENT => {}},
    }
    
    h[:header]= Label_header_info.new if process[:"header"]
    h[:info]  = Label_sample_info.new   if process[:"info"]
    #h[:spec]  = Block_spec.new   if @process[:"spec"]
    h[:uncl]  = Label_uncl.new           if process[:"uncl"]
    h[:param] = Label_spectral_param.new  if process[:"param"]
    h[:data]  = Label_spectral_data.new   if process[:"data"] 
  h.each_pair{|k,v| self[k]=v}
  
  self
end

def uniq_ldrs
  lab=[]
  k=self.keys
  line=[]
  k.each{|key| t=self[key]
   
     (t.is_a?(Hash)   &&   lab += t.keys) || ( t.respond_to?(:members) && t.members.each{|m| t[m] && lab << m})
   }
 
  lab.compact.uniq
end
def uniq_ldrs_o
  lab=[]
  k=self.keys
  line=[]
  k.each{|key| t=self[key]
   
     (t.is_a?(Hash)   &&   lab += t.keys) || ( t.respond_to?(:members) && t.members.each{|m| t[m] && lab << m})
   }
 
  lab.compact.uniq
end


end

class Blueberry<Hash
  
  attr_reader :alias_table, :comment
  
  alias :members :keys
  
  def initialize(h={:library => :jcampdx})
    @alias_table=Hash.new
    @comment=Hash.new
    @inc=nil
    @library=h[:library]
  end
  
  def push(k,val,inc=false)
    return if !k.is_a?(String) && !k.is_a?(Symbol)
    ## remove non-word characters
    ks=k.sanitized_ldr.to_sym
    ##   
    define_method(ks){self.[](ks)}
    ##  Save aliased key name
    @alias_table[ks]=k.to_sym
    ## Trim comment
      
    if val.is_a?(String) && val.to_s =~ /(\$\$)/       
              @comment[ks] ||=[[]]
              @comment[ks][-1] += [$'.strip]  if !inc && $'
              @comment[ks]     +=[[$'.strip]] if  inc && $'
              val=$` || ""
    end
    v=v=self.fetch(k,[[]])
    if inc
      
      
    else
    end
    val= !val.nil? && ((val.is_a?(String) && [val.strip])|| [val])
             v=self.fetch(k)
             v=(v  && v.is_a?(Array) && v[-1] && v) || [[]]
             (!inc && v[-1] += val) || (inc && v += [val] ) 

          self.olde(k,v)
  end
  
end

class Rapere<Array
   include Data_structure
 
 def init(process={})
    h=Turutu.new(process)
    h[:kai][:'kai_BLOCK_ID']=self.size
    self << h
    self
  end
  
  def ldr
    lab=[]
    self.each{|turutu| 
                    
                     lab << turutu.uniq_ldrs}
    lab
  end
  
  def to_ro
    # self.each{|i|dummy=i.dup; dummy[:flotr2_point], dummy[:raw_point]=nil,nil;puts '<'*80
     # dummy.each_pair{ |k,v|  a=k.inspect;b=v.inspect  ;puts a+' '*(27-a.size)+'= '+b if ([k]-Label_spectral_param_NMR_sym)==[] }
    # }
   
    h=Hash.new
    lab=self.ldr.flatten.uniq
    lab_=lab-Label_kaitatari_sym
   
   lab.each{|l|  h[l]=Array.new(self.size)
                 self.each_with_index{|block,i| 
                                    LDR.each{ |group|   if block.key?(group)
                                        g=block[group]
                                        if g.true_member?(l)                                           
                                            h[l][i]=self[i][group].fetch(l,[],0..-1)
                                       end
                                       end
                                       }
                }}
    h[:ldr]=Array.new(self.size)
    for j in 0..self.size do h[:ldr][j]=lab_ ;end
                                       
    [:raw_point, :processed_point, :flotr2_point].each{|group| h[group]=[]
                                                               self.each_with_index{|block,i| h[group]<< self[i][group]}}                    
      
    Ropere.new(h)  
    
   
  end
end

class Ropere<Hash
  attr_reader :dim
  include Data_structure
  include Pseudo_digit
  alias  :members :keys

  def initialize(h={:raw_point=>[], :processed_point=>[], :flotr2_point=>[]})
     
    h.each_pair{|key,v| self[key]=v}
    @dim=block_num
      @sanitized_members=self.keys.map{|s| s.sanitized_ldr}
      @sanitized_regexp=Regexp.new(/^(#{@sanitized_members.join('|')})/)
      @truename=Hash[@sanitized_members.zip(self.members)]    
      @originalname=@truename.invert
        self
  end
  
  def fetch(k,ret=nil)
       self.send(:[],k.sanitized_ldr.to_sym) ||self.send(:[],k.to_sym) || ret
  end 
     
  def block_num
     k=self.keys
     d=0
     k.each{|m| self[m].is_a?(Array) && d=[self[m].size,d].max}
     d
  end
   
   def fill_header(ldr2=nil,cond=nil)
     self.fill_ldr(Label_header_info_sym,ldr2,cond)
     self
   end
   
   def fill_ldr(symb_list=Label_header_info_sym,ldr2,cond)
     if ldr2 && ldr2.is_a?(Symbol) && cond.is_a?(String)
        symb_list.each{|lab| self[lab] &&  self[ldr2]  && self[lab].each_with_index{|e,i| i>0  && (self[ldr2][i.pred].to_s =~ /#{cond}/i) && (self[ldr2][i].to_s =~ /#{cond}/i) && self[lab][i]||=self[lab][i.pred] }}  
     else       
        symb_list.each{|lab| self[lab] &&   self[lab].each_with_index{|e,i|  self[lab][i]=(i>0 && e || self[lab][i.pred])}}  
     end
     self
   end  
   
   
   def detect(attribute=:method,b=nil)
     m=[]

     if attribute == :method
       dt=self.fetch(:"DATA TYPE")
       if dt && dt.to_s =~ /NMR/i
         mt = "NMR"
        
         
         on = self.fetch(:".OBSERVE NUCLEUS")
         sn = self.fetch(:".SOLVENT NAME")
         of = self.fetch(:".OBSERVE FREQUENCY") 
           
          #"detected NMR \n"+on.inspect+"\n"+sn.inspect+"\n"+of.inspect   
       end
     end
     if attribute == :title
       dt=self.fetch(:"DATA TYPE")
       ti= self.fetch(:"TITLE")
       if dt &&  dt.to_s =~ /NMR/i
            ps= self.fetch(:".PULSE SEQUENCE")
       end  
     end
      
      for i in 0..@dim
               
        if attribute == :method     
          if dt 
            if dt[i].to_s =~  /NMR/i
              
             m[i]=(on && on[i].is_a?(Array) && sn && sn[i].is_a?(Array) && of && of[i].is_a?(Array) && (mt+"/"+on[i].flatten[0].to_s.gsub(/\^/,"")+"/"+sn[i].flatten[0].to_s+"/"+of[i].flatten[0].to_s.to_f.round.to_s)) || mt 
            else 
             m[i]=dt[i] || "n.d."
            end
          end  
         
        elsif attribute == :title
         t  =  (ti && ti.fetch(i,nil).is_a?(Array) && ti.fetch(i).flatten.fetch(0,"").to_s) || "" 
         pu =  (ps && ps.fetch(i,nil).is_a?(Array) && ps.fetch(i).flatten.fetch(0,"").to_s ) || ""
         m[i] = t+" - "+pu
        
        else
          
       end      
     end
     ind= self.map_ind4data.compact
     #puts ind.inspect
    
         r= m[ind[0]]    if !b
         r= m if b.to_s =~ /all/   
         r.is_a?(Array) && r.flatten.compact.join(" , ") || r.to_s                        
   end #of method detect
   
   
   def detect_and_fill
    self.fill_header
    type=self[:'DATA TYPE']
    
    if type
      
     type.to_s =~ /(NMR)\s*SPECTRUM/i && self.fill_ldr(Label_spectral_param_NMR_sym,:'DATA TYPE',"NMR")
     
    end                                
    if self[:UNITS]
        unit = Array.new(self[:UNITS].size)
        fact = Array.new(self[:UNITS].size)
        self[:UNITS].each_with_index{|b,j| if b 
                                            unit[j]= Array.new(b.size)
                                            fact[j]= Array.new(b.size)
                                            b.each_with_index{|var,i|  if var.to_s =~ /^\s*(hz|HERTZ)/i
                                                                         unit[j][i]="ppm"
                                                                   
                                                                       
                                                                         fact[j][i]=(self[:".OBSERVE FREQUENCY"].is_a?(Array) && self[:".OBSERVE FREQUENCY"][j].is_a?(Array) && (s=self[:".OBSERVE FREQUENCY"][j].flatten[0].to_f) && 1/s) || 1
                                                                        else
                                                                         unit[j][i]=self[:UNITS][j][i]
                                                                         fact[j][i]=1
                                                                        end}  end }                           
    self[:kUNITS] = unit
    self[:kFACTOR]= fact
    end
 
################# 
     # dummy=self.dup; dummy[:flotr2_point], dummy[:raw_point]=nil,nil;puts '<'*80
     # dummy.each_pair{ |k,v|  a=k.inspect;b=v.inspect  ;puts a+' '*(27-a.size)+'= '+b if ([k]-Label_spectral_param_NMR_sym)==[] }
      # [:raw_point,:flotr2_point].each{|s| puts s.to_s+' '*(20-s.to_s.size)+'='+self[s].inspect.slice(0..40)};puts ">"*80 
##########    
    self
   end # end of method detect_and_fill
   
   def map_ind4ldr(lab)
     ##return array of indices for which ropere has a !nil value at lab
    return if !lab.is_a?(Symbol)
     
    # if lab==:raw_point ||lab==:processed_point ||lab==:flotr2_point
      # self[lab] && ind=self[lab].map.with_index{|e,i| e=(e && e!=[] && i )|| nil }.compact!
    # else 
    ind=[]
    lab=@truename[lab] || lab
   
    
     self[lab] && self[lab].each_with_index{|e,i|  
                                                       ind +=[(e && e!=[] && i )|| nil] }
    # end 
  
     ind.compact!
    
     ind
   end   
   
   def slice_4ind(ind)
    ke= self.keys
    h={}
    size=self.dim
   
    ke.each{|k| h[k]=[]
               ind.each{|i| i.is_a?(Integer) && i<size && h[k] << self[k][i] }}
    Ropere.new(h)            
   end
   
   def slice_4ldr(lab)
     i=self.map_ind4ldr(lab)
     self.slice_4ind(i)
     
   end   
   
   def slice(o)
     r={}
     if o.is_a?(Symbol)
       r[o]=self[o]
     elsif o.is_a?(Integer) && o < self.dim
       self.each_pair{|k,v| r[k]=v[o]}
     end
      r
   end
   
   def to_flotr2(page=[0],type=:XYDATA)
    ##type XYDATA
     
     rp= self[:raw_point]
     rp.each_with_index{|e,i| if self[:XYDATA] || self[:'XYPOINTS'] || self[:'DATA TABLE'] || self[:'PEAK TABLE']
                              self[:flotr2_point][i]=Array.new(e.size)
                              for j in page
                              (d=e[j]) && d[:x] && d[:y] && self[:flotr2_point][i][j]=d.xy   
                              end  
                              end}
       
     
     
    ##type peak list
    ##todo
    ##
    self
   end
   
   def map_ind4data
     ind=[]
     #:'XYDATA',:'XYPOINTS',:'DATATABLE',:'PEAKTABLE',
     [:raw_point,:flotr2_point].each{|s|  ind += self.map_ind4ldr(s)}
     ind.sort.uniq
   end
   
   def to_kumara
     ind=self.map_ind4ldr(:flotr2_point)
     s=ind.size
   
     h=Moa.new
     h.members.each{|m| h[m]=Array.new(s)}
     ind.each_with_index{|i,q|       
       h.indx[q]=self[:SYMBOL_INDEX][i].map{|e| e[0]}
       h.indy[q]=self[:SYMBOL_INDEX][i].map{|e| e[1]}
       h.indz[q]=self[:kai_indn][i]||[]
       h.indn[q]=self[:kai_indn][i]||[]
       ix=h.indx[q]
       iy=h.indy[q]
       ixy=ix.zip(iy)
       h.xy[q]=self[:flotr2_point][i]
       h.TITLE[q] = self[:TITLE][i]*" : "
       h.TYPE[q] = self[:kai_DATA_TYPE][i]
       h.CLASS[q] = self[:kai_DATA_CLASS][i]
       h.kai_BLOCK_ID[q]=self[:kai_BLOCK_ID][i]
       h.xaxis_reversed[q]=(self[:x_reversed] && self[:x_reversed][i]) || Array.new(h.xy[q].size).map{|e| false}
       temp={}
       self[:ldr][i].each{|s| self[s].is_a?(Array) && self[s][i]  && temp[s]=self[s][i].join("\n")}
       h.ldr[q]= temp ##.to_json
       
       [:SYMBOL,:VAR_NAME,:kUNITS,:UNITS,:FACTOR,:kFACTOR].each{|s| 
                                                h[s][q]=[]
                                                ixy.each{|j|h[s][q]<<[self[s][i][j[0]],self[s][i][j[1]]]}
                                                }
        r=self[:raw_point][i]
        temp=Array.new(r.size)
        [:page,:z].each{|s| h[s][i]=Array.new(r.size)}
        r.each_with_index{|e,j| h.page[q][j]=r[j][:n]
                                    h.z[q]  =r[j][:z]}
      
                          }
     #################
     
     #dummy=h.dup;  dummy.xy=nil;dummy.each_pair{ |k,v|  a=k.inspect;b=v.inspect ; puts a+' '*(20-a.size)+'= '+b }
     #puts 'xy'+' '*18+'='+h.xy.inspect.slice(0..20)
     ###################
     Kumara.new(h)
   
   end# of method to_ro
      
end #of class
 
Moa=Struct.new(:TITLE,:TYPE,:CLASS,:SYMBOL,:VAR_NAME,:indx,:indy,:indz,:indn,:xaxis_reversed,:kUNITS,:UNITS,:FACTOR,:kFACTOR,:page,:z,:xy,:kai_BLOCK_ID,:ldr)

class Kumara<Moa  #<Ropere# #todo structure vs Hash
   
   def initialize(h=nil)
    
     h && Moa.members.each{|m|   #
                                 h[m] && self[m]=h[m]}
     
     check || (b=Kumara.blank && Moa.members.each{|m|  self[m]=b[m]})
     
   self
   end
   
   def self.blank
     m=Kumara.new
     m.TITLE=["nd"]
     m.TYPE=[["nd"]]
     m.CLASS=[["nd"]]
     m.SYMBOL=[["x","y","z","n"]],
     m.VAR_NAME=[["abs","ord","ord2","page"]]
     m.indx=[[0]]
     m.indy=[[1]]
     m.indz=[[2]]
     m.indn=[[3]]
     m.xaxis_reversed=[[false]]
     m.kUNITS=[["arbitrary units"]]
     m.UNITS=[["arbitrary units"]]
     m.FACTOR=[[1,1]]
     m.kFACTOR=[[1,1]]
     m.page=[[0]]
     m.z=[[0]]
     m.xy=[[[[10,10], [90,90], [50,50], [10,90],[90,10]]]]
     m.kai_BLOCK_ID=[[-1]]
     m.ldr=[ {:'TITLE' => '..',:'OWNER'=> '..'}] #{:'Headers'=>
     m
   end
   
   def blank
     m=Moa.new
     m.TITLE=["nd"]
     m.TYPE=[["nd"]]
     m.CLASS=[["nd"]]
     m.SYMBOL=[["x","y","z","n"]],
     m.VAR_NAME=[["abs","ord","ord2","page"]]
     m.indx=[[0]]
     m.indy=[[1]]
     m.indz=[[2]]
     m.indn=[[3]]
     m.xaxis_reversed=[[true]]
     m.kUNITS=[["arbitrary units"]]
     m.UNITS=[["arbitrary units"]]
     m.FACTOR=[[1]]
     m.kFACTOR=[[1]]
     m.page=[[1]]
     m.z=[[0]]
     m.xy=[[[[10,10], [90,90], [50,50], [10,90],[90,10]]]]
     m.kai_BLOCK_ID=[[-1]]
     m.ldr=[ {:'TITLE' => '..',:'OWNER'=> '..'}] #{:'Headers'=>
     Moa.members.each{|k|   self[k]=m[k]}
   end
   
   def check
    r= Moa.members.map{|m|  (self[m].is_a?(Array) && self[m].size )|| nil}
    r.size == Moa.members.size &&    r.max == r.min
   end
   
   def no_data(i=nil)
     temp=self[xy]
     
     if i.is_a?(Integer) &&temp.is_a?(Array) && temp.size > i && temp[i].nil?
       self[xy][i]= [[10,10], [90,90], [50,50], [10,90],[90,10]]
        elsif temp.nil?
          self[xy]=[[10,10], [90,90], [50,50], [10,90],[90,10]]
            end
            
            
        #temp.is_a?(Array) && temp.flatten == [] i<self[xy].size
     # end
     self[xy]=[[[10,10], [90,90], [50,50], [10,90],[90,10]]]
   end
   def slice(i)
     moa=Kumara.new
     memb=moa.members.each{|m|  if self[m].is_a?(Array) && self[m].size > i
                            moa[m]=self[m][i]
                             
                            end }
     moa
   end

   def chip_it(r=0..-1,block=0,page=0,limit=2048)  
   kaka=self.slice(block)
   
   
   [:TYPE,:SYMBOL,:xaxis_reversed,:kUNITS,:UNITS,:FACTOR,:kFACTOR,:xy,:z,:page].each{|m| kaka[m]=kaka[m][page]}
   
   kaka.xy=kaka.xy.trim_point(r,limit)
 # Moa.members.each{|m|   puts "Kumara chip"+m.inspect+" = "+kaka[m].inspect.slice(0..60) }
 # kaka[:ldr].each_pair{|s,v| puts "Kumara chip ldr :"+s.inspect+" = "+v.inspect.slice(0..60)}
 # puts 'json  html : '+ kaka[:ldr].to_json.html_safe.inspect.slice(0..80)
   kaka 
 
   end


  

  
end #of class Moa

end #end of module