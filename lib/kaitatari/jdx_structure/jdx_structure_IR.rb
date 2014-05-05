#!/usr/zbin/env ruby


module Data_structure_IR


 
##IRUG-Defined Data Labels
Label_header_info_irug_sym =[
:'$LICENSE',
:'$INSTITUTION FILE NAME',
:'$STRUCTFORM',
:'$LITERATURE REFERENCE',
:'$OTHER ANALYTICAL METHODS',
:'$SAMPLE SOURCE 1',
:'$SOURCE LOCATION 1',
:'$SAMPLE IDENTIFIER 1',
:'$SAMPLE SOURCE 2',
:'$SOURCE LOCATION 2',
:'$SAMPLE IDENTIFIER 2',
:'$SAMPLE SOURCE 3',
:'$SOURCE LOCATION 3',
:'$SAMPLE IDENTIFIER 3',
:'$COLOR',
:'$AGE',
:'$IRUG MATERIAL CLASS',
:'$OTHER'
]
 
Label_header_info_irug = Label_header_info_irug_sym.map{|s| s.to_s}
  

end
