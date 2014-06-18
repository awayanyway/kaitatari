#!/usr/zbin/env r{}uby
############https://gist.github.com/jbr/823701
# class Object
  # def switch( hash )
    # hash.each {|method, proc| return proc[] if send method }
    # yield if block_given?
  # end
# end
# 
# module Kernel
  # def switch!( thing, hash, &blk )
    # thing.switch hash, &blk
  # end
# end

# The above code allows us to do this:

#offer.switch(available: -> { order.submit },
#             cancelled: -> { order.reject },
#             postponed: -> { order.postpone }) { raise UnknownStateError.new }
#########################################
#########################################



class Object
  def switch( hash )
    
    hash.each do |method, proc|
       return proc[] if method == :Default || send( method )
    end
  end
  
  
def meta_build(clas)
   
   if clas.class == Class && clas.respond_to?(:superclass) && clas.superclass == Struct
    
      clas.class_eval do 
        attr_reader :sanitized_members, :sanitized_regexp, :comment
        self.members.each{|s|     str=s.to_s
                                  if str =~ /[^a-zA-Z0-9]/
                                  m=s.sanitized_ldr
                                  define_method(m){self.old(s)}
                                  define_method(m.to_s.concat('=').to_sym){|val| self.olde s, val}
                                  end
                                  }
        alias :keys :members                          
        
        def initialize
          @sanitized_members=self.members.map{|s| s.sanitized_ldr}
          @sanitized_regexp=Regexp.new(/^(#{@sanitized_members.join('|')})/)
          @truename=Hash[@sanitized_members.zip(self.members)]    
          @originalname=@truename.invert
          @comment = Hash.new
          @alias_table= Hash.new
        end 
        
        def [](key) 
          fetch(key.sanitized_ldr.to_sym,[],-1)
          
        end 
         
        def []=(key, val,inc=nil)
          k=key.sanitized_ldr
          ktrue=@truename[k.to_sym]
          if ktrue 
             @alias_table.olde(key,k)
             if  val.to_s =~ /(\$\$)/       
                @comment[k] ||=[[]]
                @comment[k][-1] += [$'.strip]  if !inc && $'
                @comment[k]     +=[[$'.strip]] if  inc && $'
                val=$` || ""
             end
             val= (val.is_a?(String) && [val.strip])|| [val]
             v=self.fetch(k,[[]])
             !inc && ( v[-1] << val) || (v << [val] )
             self.olde(ktrue,v)
           else nil
           end                                          
         end                                                                          
         
        def copy(key,val)
          k=true_member?(key)
          k && self.olde(k,val)
        end     
                                                                      
        def true_member?(m)                                                                                                            
         @truename[m.sanitized_ldr.to_sym] || false
        end
        
        def fetch(key,ret=nil,range=0..-1)
          m=key.sanitized_ldr.to_sym
          r=(self.respond_to?(m) && self.send(m)) || ret
          (r.is_a?(Array) && r[range])|| r
        end  
     end
  
      clas.instance_eval do
    alias :keys :members
     def self.sanitized_members        
    @sanitized_members||=self.members.map{|s| s.sanitized_ldr}
    end
    
    def self.sanitized_regexp          
      @sanitized_regexp||=Regexp.new(/^(#{sanitized_members.join('|')})/)
    end
    
    def self.truename
      #return @truename if @truename
      @truename ||= Hash[self.sanitized_members.zip(memb)]       
    end
    
    def self.originalname
      #return @originalname if @originalname
      @originalname||=self.truename.invert
    end
  end 
  
   end

   if clas.superclass == Hash
      clas.class_eval do 
        attr_reader :comment #, :sanitized_members, :sanitized_regexp
               # self.keys.each{|s|     str=s.to_s
                              # if str =~ /[^a-zA-Z0-9]/
                              # m=s.sanitized_ldr
                              # define_method(m){self.old(s)}
                              # define_method(m.to_s.concat('=').to_sym){|val| self.olde s, val}
                              # end
                                 # }
       alias :members :keys                          
       
       def initialize
         #@sanitized_members=self.keys.map{|s| s.sanitized_ldr}
         #@sanitized_regexp=Regexp.new(/^(#{@sanitized_members.join('|')})/)
         #@truename=Hash[@sanitized_members.zip(self.keys)]    
         #@originalname=@truename.invert
         @comment = Hash.new
         @alias_table=Hash.new
       end 
       
       def sanitized_members
         self.keys.map{|s| s.sanitized_ldr}
       end
       
       def sanitized_regexp
         Regexp.new(/^(#{self.sanitized_members.join('|')})/)
       end
       
       def truename
         Hash[self.sanitized_members.zip(self.keys)]
       end 
       
       def originalname
         self.truename.invert
       end
       
       def [](key) 
         self.old(key) || ((a=@alias_table.old(key)) && self.old(a))
       end 
        
       def []=(key, val,inc=false)
          k=key.sanitized_ldr
          @alias_table.olde(key,k)
          if  val.to_s =~ /(\$\$)/       
              @comment[k] ||=[[]]
              @comment[k][-1] += [$'.strip]  if !inc && $'
              @comment[k]     +=[[$'.strip]] if  inc && $'
              val=$` || ""
          end
            val= (val.is_a?(String) && [val.strip])|| [val]
         
             v=self.fetch(k,[[]])
            
             (!inc && v[-1] += val) || (inc && v += [val] ) 

          self.olde(k,v)
        end
       def copy(key,val)
          k=key.sanitized_ldr
          k && self.olde(key,val)
        end    
       def true_member?(m) 
       ( self.key?(m) && m )|| @alias_table.fetch(m,false)
       end
       
        def fetch(k,ret=nil,range=0..-1)
          true_member?(k) || k=k.sanitized_ldr.to_sym
         r= self.old(k)  || ret
        
         (r.is_a?(Array) && r[range]) || r
        end
       
     end
   end  
end
end

 


# module Kernel
  # def switch!( thing, hash ) thing.switch hash end
# end

# The above code allows us to do this:
# offer.switch available: -> { order.submit },
# cancelled: -> { order.reject },
# postponed: -> { order.postpone },
# Default: -> { raise UnknownStateError.new }
#  
#  
# switch! offer,
# available: -> { order.submit },
# cancelled: -> { order.reject },
# postponed: -> { order.postpone },
# Default: -> { raise UnknownStateError.new }


 module Kernel
  def switcher(thing, hash)
    hash.each do |method, proc|
      return proc[] if method == :Default || thing.send(method)
    end
  end
end