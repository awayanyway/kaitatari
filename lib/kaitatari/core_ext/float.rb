require 'bigdecimal'

class Float
  
  def to_d(precision=nil)
  BigDecimal(self, precision || Float::DIG+1)
  end
   
end
