class Postscript_output
  
attr_reader :output_text 
 
 def initialize(opt={})
   opt[:size] ||= [11.7,8.3,"inch"] 
   @size=(opt[:size][0].is_a?(Float) && opt[:size][1].is_a?(Float) && opt[:size]) || [11.7,8.3, "inch"] 
   @scale = (opt[:size][2] =~ /(inch|mm|cm|m)/ && $1 ) || (opt[:scale] =~ /(inch|mm|cm|m)/ && $1 ) || "inch"
   if @scale =~ /cm/
     @size= [@size[0]/2.54, @size[1]/2.54]
   elsif @scale =~ /mm/
     @size= [@size[0]/25.4, @size[1]/25.4]
   elsif  @scale =~ /m/
     @size= [@size[0]/0.254, @size[1]/0.254]
   end
   # if @size[0] > @size[1]
     # @size[0],@size[1] = @size[1],@size[0]
     # @rotate="yes"
   # end 
   @resolution= (opt[:resolution] && opt[:resolution].to_f) || 600.0  #72dpi
   @size_point = @size.map{|e| (e*72).floor if e.is_a?(Float)}
   #lower left and upper rigth corner cordinates of the graph window [x1,y1,x2,y2] 
   #in page fraction
   @graph_position=opt[:graph_position] || [1/20.0,1/20.0,15/20.0,18/20.0]  
   #in points values
   @graph=Array.new(4){|i| (@size_point[i.modulo(2)]* @graph_position[i]).round }
   if opt[:data]
     opt[:data_x]=opt[:data][1][1][0]
     opt[:data_y]=opt[:data][1][1][1]
     @ldr=opt[:data][0]
   end
   @data_x= opt[:data_x] || [0]
   @data_y= opt[:data_y] || [0]
   @xy_arr= @data_x.zip(@data_y) 
   @output_file=opt[:output_file] 
   @output_text = "%!PS-Adobe-3.0\n"
   @output_text << "<< \/PageSize [#{@size_point[0]} #{@size_point[1]}]/Orientation 0 >> setpagedevice\n"
   #@output_text<<"90 rotate 0 -#{@size_point[1]} translate\n" if @rotate  
   
   @scaling=72.0/@resolution.round(5)
 end
 
  def jdx2ps
    build_ps
    puts "#{__method__} in file: #{file}" 
    return output_text
  end

def build_ps
  prepare_xyarr
  draw_box
  write_ldr
  draw_line
  
  return @output_text  
end


 private
 def data_to_point(data_array,axe=0,margin=0.0)
   #data points are scaled to integer values and offset to the graph windows
  # puts "@size=#{@size} @scale=#{@scale} @size_point=#{@size_point} 
  #  @resolution=#{@resolution} @graph_position=#{@graph_position}
  # @graph=#{@graph}"
   
   max=data_array.max
   min=data_array.min
   d=max-min
   f=(@graph[axe+2]-@graph[axe])*@resolution/72.0 * (1-margin) / (d)
   #puts "axe=#{axe} min =#{min} max=#{max} f=#{f} \n #{@graph}"
   a=data_array.map{|e| ((e-min) * f + @graph[axe]).round}
   #a=data_array.map{|e| ((e-min) * f ).round}
   return a
 end

 
 def prepare_xyarr(x=@data_x,y=@data_y,margin=0.1) 
   @xy_arr = data_to_point(x).zip(data_to_point(y,1,margin))
   return @xy_arr
 end
 
 def write_ldr
    
    x,y = @graph[2],@graph[3]
    t= "/Arial findfont\n12 scalefont\nsetfont\nnewpath\n"
    t<< "#{x} #{y} moveto\n"
    @ldr.each_pair{|k,v|
                if v.is_a?(Array)
                val=v.join(", ")
                else
                val=v
                end
                t<< "(  #{k} = #{val}) #{x} #{y -= 12} moveto show\n"
                }
   @output_text << t
   end
 def draw_box
   t = "newpath \n#{@graph[0]} #{@graph[1]} moveto\n"
   t << "  #{@graph[0]} #{@graph[1]} #{@graph[0]} #{@graph[3]} #{@graph[2]} #{@graph[3]} #{@graph[2]} #{@graph[1]} lineto lineto lineto lineto\n"
   t << "0.5 setlinewidth\nstroke\n"
   @output_text << t
 end
 
 def draw_line(xyarr=@xy_arr)
   s= xyarr.size - 11
   temp=Array.new(s+1)
   t="\/l \{ "+ "lineto "*10 +"\} def \n"
   t << "#{@graph[0]} #{@graph[1]} translate\n"
   t << "#{@scaling} #{@scaling} scale\n"
   
   t << "newpath \n#{xyarr[0][0]} #{xyarr[0][1]} moveto\n"
   j=0
   while j < s
   temp[j..(j+10)]=xyarr[j..(j+10)].reverse
   10.times{e=temp[j]
            t << "#{e[0]} #{e[1]} "  
            j+=1}
   t <<  "l\n"
   end
   while e=xyarr[j]                                
   t << "#{e[0]} #{e[1]} lineto\n"
   j+=1
   end
   
   t << "0.5 setlinewidth\nstroke\n"
   
   @output_text << t
   return @output_text
 end
 
 
 
 def paper_size
  #with 72 dpi
  #Paper Size                      Dimension (in points)
  #------------------              ---------------------
  @size_hash={
   :Comm_10_Envelope     =>           [297 , 684 ]  ,
   :C5_Envelope          =>           [461 , 648 ]  ,
   :DL_Envelope          =>           [312 , 624 ]  ,
   :Folio                =>           [595 , 935  ] ,
   :Executive            =>           [522 , 756  ] ,
   :Letter               =>           [612 , 792  ] ,
   :Legal                =>           [612 , 1008 ] ,
   :Ledger               =>           [1224 , 792 ] ,
   :Tabloid              =>           [792 , 1224 ] ,
   :A0                   =>           [2384 , 3370] ,
   :A1                   =>           [1684 , 2384] ,
   :A2                   =>           [1191 , 1684] ,
   :A3                   =>           [842 , 1191 ] ,
   :A4                   =>           [595 , 842  ] ,
   :A5                   =>           [420 , 595  ] ,
   :A6                   =>           [297 , 420  ] ,
   :A7                   =>           [210 , 297  ] ,
   :A8                   =>           [148 , 210  ] ,
   :A9                   =>           [105 , 148  ] ,
   :B0                   =>           [2920 , 4127] ,
   :B1                   =>           [2064 , 2920] ,
   :B2                   =>           [1460 , 2064] ,
   :B3                   =>           [1032 , 1460] ,
   :B4                   =>           [729 , 1032 ] ,
   :B5                   =>           [516 , 729  ] ,
   :B6                   =>           [363 , 516  ] ,
   :B7                   =>           [258 , 363  ] ,
   :B8                   =>           [181 , 258  ] ,
   :B9                   =>           [127 , 181  ] ,
   :B10                  =>           [91 , 127   ] 
  }
  unless @resolution == 72
    @size_hash.each_pair{|k,v| @size_hash[k]=v.map{|e| e/72.0* @resolution.floor }}
  end
  return @size_hash
  end
  
end
