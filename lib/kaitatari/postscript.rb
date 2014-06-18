class Postscript_output
  
attr_reader :output_text 
 
 def initialize(opt={})
   # 
  
   p = opt[:page] || 0   
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
   @graph_position=opt[:graph_position] || [1/20.0,1/20.0,15/20.0,19/20.0]  
   @graph_ldr_position= opt[:graph_ldr_position] ||@graph_position[2..3]
   #in points values
   @graph=Array.new(4){|i| (@size_point[i.modulo(2)]* @graph_position[i]).round }
   @graph_ldr=Array.new(2){|i| (@size_point[i.modulo(2)]* @graph_ldr_position[i]).round }
   
   if opt[:data] && !opt[:data_xy]
     #opt[:data_x]=opt[:data][2][0][0]  
     if !opt[:data_y] 
        if    opt[:data][:raw_point]        && opt[:data][:raw_point][0]       && opt[:data][:raw_point][0][:y].size >0 
              opt[:data_y] =  opt[:data][:raw_point][0][:y] 
              opt[:data_x] = (opt[:data][:raw_point][0][:x].size       == opt[:data_y].size && opt[:data][:raw_point][0][:x])       || [*1..opt[:data_y].size]
        end
     end
     if opt[:point].to_s =~ /processed/
        if    opt[:data][:processed_point]  && opt[:data][:processed_point][0] && opt[:data][:processed_point][0][:y].size >0 
              opt[:data_y] =  opt[:data][:processed_point][0][:y]
              opt[:data_x] = (opt[:data][:processed_point][0][:x].size == opt[:data_y].size && opt[:data][:processed_point][0][:x]) || [*1..opt[:data_y].size]
        elsif opt[:data][:raw_point]        && opt[:data][:raw_point][0]       && opt[:data][:raw_point][0][:y].size >0 
              opt[:data_y] =  opt[:data][:raw_point][0][:y] 
              opt[:data_x] = (opt[:data][:raw_point][0][:x].size       == opt[:data_y].size && opt[:data][:raw_point][0][:x])       || [*1..opt[:data_y].size]
        end
     end
     opt[:ldr]=opt[:data][:h]
   end
   
   @margin = opt[:margin]||[0.0,0.0] 
   
   @offset ||=[0,0]
   @ldr = opt[:ldr] || {}
   if opt[:data_xy]
     opt[:data_x],opt[:data_y]=opt[:data_xy].transpose
   end
   @data_y= opt[:data_y] || [1]
   @data_x= opt[:data_x] || [*1..@data_y.size]
   
   @xy_arr= opt[:data_xy] || @data_x.zip(@data_y) 
   #puts @xy_arr.inspect.slice(0..100)
   @output_file=opt[:output_file] 
   @output_text = "%!PS-Adobe-3.0\n"
   o=opt[:orientation].to_s
   o=0 unless o =~ /\A0|1|2|3\z/ 
   @output_text << "<< \/PageSize [#{@size_point[0]} #{@size_point[1]}]/Orientation #{o} >> setpagedevice\n"
   #@output_text<<"90 rotate 0 -#{@size_point[1]} translate\n" if @rotate  
   @scaling=72.0/@resolution.round(5)
   @fx=(@graph[2]-@graph[0])*@resolution/72.0 * (1-@margin[0])
   @fy=(@graph[3]-@graph[1])*@resolution/72.0 * (1-@margin[1])
   @f=[@fx,@fy]
   lw=opt[:line_width]
   @line_width=(lw && lw.is_a?(Numeric) && lw>0.1 && lw<5.0 && lw )||0.5
   lw=opt[:scale_font]
   @scale_font=(lw && lw.is_a?(Numeric) && lw>1.0 && lw<35.0 && lw )||8.0
   @linespace=@scale_font*1.5
 end
 
  def jdx2ps
    build_ps
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
 def data_to_point(data_array=@data_x,axe=0,margin=@margin[0])
   #data points are scaled to integer values and offset to the graph window
   max,min=data_array.max,data_array.min
   f= @f[axe]/ (max-min)
   #f_log "axe=#{axe} min =#{min} max=#{max} f=#{f} \n #{@graph}"
   a=data_array.map{|e| ((e-min) * f ).round}  #+ @graph[axe]
   
   return a
 end

 
 def prepare_xyarr(x=@data_x,y=@data_y,margin=@margin) 
   @xy_arr = data_to_point(x,0,margin[0]).zip(data_to_point(y,1,margin[1]))
   return @xy_arr
 end
 
 def write_ldr
    
    x,y = @graph_ldr[0],@graph_ldr[1]
    t= "/Arial findfont\n#{@scale_font} scalefont\nsetfont\nnewpath\n"
    t<< "#{x} #{y} moveto\n"
    if @ldr
    @ldr.each_pair{|k,v|
                if v.is_a?(Array)
                val=v.join("\n")
                else
                val=v
                end
                t<< "(  #{k} = #{val}) #{x} #{y -= @linespace} moveto show\n"
                }
    end
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
   
   t << "#{@line_width} setlinewidth\nstroke\n"
   
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
