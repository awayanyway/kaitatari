class Array
 
 
 def trim_point(range=0..-1,limit=4096)
  
    xy=self[range]
    if (s=xy.size) > limit
      trim_rate = 2*s/limit.floor
      xy_trim = Array.new
      for i in Array.new((s/trim_rate).ceil).fill{|k| k*trim_rate}
        xy_trim << xy[i]
      end
    xy=xy_trim.compact
    end
    xy
  end
  
   
  def sample_point(limit=4096)
    # # #sample data points
    xy=[]
     if (s=self.size) > limit
       samp_rate = 2*s/limit.floor
       xy_samp =  Array.new(samp_rate){Array.new}
       for i in Array.new((s/samp_rate).ceil).fill{|k| k*samp_rate}
         xy_samp.each.with_index{|c,j| c<<self[i+j]}
       end
       xy =  xy_samp.map{|m| m.compact}
     end
     xy
   end
   
end