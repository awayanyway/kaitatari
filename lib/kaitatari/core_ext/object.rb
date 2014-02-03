#!/usr/zbin/env ruby
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
      
      #puts "method #{method} proc #{proc}"
      return proc[] if method == :Default || send( method )
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