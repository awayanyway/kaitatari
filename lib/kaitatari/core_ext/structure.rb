# require 'ostruct'
#
# class OpenStruct
# #missing in 1.9.3
# def [](name)
# @table[name.to_sym]
# end
#
# def []=(name, value)
# modifiable[new_ostruct_member(name)] = value
# end
#
# end
#
class Struct
  
  def keys
    self.members
  end
  
  def merge_and_compact(*p)
    #merge two instances of struct in a new struct instance named by a constant if a string (with first letter capital) is given
    #remove duplicate members and arrayize value for duplicated key with non nil values
    #remove key with nil values
    struct_to_merge=[self]
    constant_name, memb, val = nil,[],[]
    p.each{|e|
      struct_to_merge << e if e.is_a?(Struct)
      (constant_name=(e =~ /^[A-Z]/ && e.slice(0..20).gsub(/[^\w\d_]/,""))||nil)  if e.is_a?(String)}

    #list all structure members  and all values
    struct_to_merge.each{|s| s.each_pair{|k,v|
        unless  v.to_s=~/^\s*\z/  # v == nil
        memb << k
        val << v
        end }}

    s=memb.size - 1
    #check for duplicated members
    memb.each.with_index{|m,i|
      temp=[]
      unless m == nil
        memb[i..s].each.with_index{|ms,j|
          if j =! 0 && m == ms  
            temp<<val[j+i]
            memb[j+i], val[j+i] = nil,nil 
          end}
      end
      val[i] = temp if temp.size > 1}
    memb.compact!
    val.compact!
    return self if memb.size < 1 #do nothing with empty structure

    if constant_name
      #return self if Object.const_get(constant_name)
      Object.const_set(constant_name,Struct.new(*memb))
      merge_struct=Object.const_get(constant_name)
    else
      merge_struct =  Struct.new(*memb)
    end
    merge_struct.new(*val)

  end
  
  def self.merge(*p)
    # merge structure class 
    # if constant string suplied associate constant to the new structure class else return the structure class
    #remove duplicated members
    memb,struct_to_merge, constant_name = [],[], nil
    p.each{|e|
      struct_to_merge << e if (e.respond_to?(:superclass) && e.superclass == Struct)
      (constant_name=(e =~ /^[A-Z]/ && e.slice(0..20).gsub(/[^\w\d_]/,""))||nil)  if e.is_a?(String)}
    struct_to_merge.each{|s| memb << s.members} 
    memb= memb.flatten.uniq
     if constant_name
      Object.const_set(constant_name,Struct.new(*memb))
     else
       Struct.new(*memb)
     end
  end

end