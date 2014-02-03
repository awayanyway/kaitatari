require 'ostruct'

class OpenStruct
  
def [](name)
  @table[name.to_sym]
end

def []=(name, value)
  modifiable[new_ostruct_member(name)] = value
end
                      
end

