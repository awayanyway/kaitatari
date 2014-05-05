module Pseudo_digit

  #Pseudo_digit = Hash[[*('a'..'i')].reverse.concat(['@',*('A'..'I')]).zip(-9..9)]

  Pseudo_digit = {
    "?" =>" ?",
    "@" =>" 0",
    "A"=> " 1",
    "B"=> " 2",
    "C"=> " 3",
    "D"=> " 4",
    "E"=> " 5",
    "F"=> " 6",
    "G"=> " 7",
    "H"=> " 8",
    "I"=> " 9",
    "a"=> " -1",
    "b"=> " -2",
    "c"=> " -3",
    "d"=> " -4",
    "e"=> " -5",
    "f"=> " -6",
    "g"=> " -7",
    "h"=> " -8",
    "i"=> " -9",
    "%"=> " x0",
    "J"=> " x1",
    "K"=> " x2",
    "L"=> " x3",
    "M"=> " x4",
    "N"=> " x5",
    "O"=> " x6",
    "P"=> " x7",
    "Q"=> " x8",
    "R"=> " x9",
    "j"=> " x-1",
    "k"=> " x-2",
    "l"=> " x-3",
    "m"=> " x-4",
    "n"=> " x-5",
    "o"=> " x-6",
    "p"=> " x-7",
    "q"=> " x-8",
    "r"=> " x-9",
    "S" => "*1 ",
    "T" => "*2 ",
    "U" => "*3 ",
    "V" => "*4 ",
    "W" => "*5 ",
    "X" => "*6 ",
    "Y" => "*7 ",
    "Z" => "*8 ",
    "s" => "*9 ",
    "+" => "  ",
    "-" => " -"
  }

  Regex_sub = /[a-zA-Z@%\-\?\+\\\/\[\]\{\}\(\)\|><:]/
  ## x AFFN at the start of line
  Regex_xread = Regexp.new(/^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:E[-+][0-9]+)?)\s*/) #([eE][-+]?[0-9]+)?
  Regex_yread = Regexp.new(/^\s*(?:(x)?((?:[-]?\d*(?:\.?\d+|\.)|\?))+)+(?:\*(\d))?\s*/)

  Regex_xyread = Regexp.new(/^\s*([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+][0-9]+)?)[ \t,]+([-+]?(?:\d*(?:\.?\d+|\.))+(?:[Ee][-+][0-9]+)?)\s*/)
  #Regex_xyread = Regexp.new(/^\s*(?:[-+]?[0-9a-sA-Z@%]+|\?)/)

  # Regex_meta  = Regexp.new(/[^\(\)\[\]\{\}\?\*]/)

  def line_x_trimer(line="")
    ## output AFFN located at the start of a line (rest of line accessible in $' until next match is called)
    line.match(Regex_xread)
    $1
  end

  def xline_generator(firstx, count, deltax=1.0, xline=[]) # float ,integer, float, string
    #x = firstx.to_f
    #deltax = deltax.to_f
    #xline = [x]
    xline = [firstx]
    count.to_i.pred.times{xline << (firstx += deltax) } #{ xline << " #{x += deltax}"}
    xline
  end

  def checkpoint(a=0.0, b=0.0,s="x", diff=0)
    check3 = (a.to_f.round(8) <=> b.to_f.round(8))
   # f_log "check <#{s}> #{a} = #{b} is #{check3 == diff}"
    check3 == diff
  end

  def line_yyy_translator(iline, iyline=[])
    iline= iline.gsub(Regex_sub, Pseudo_digit).match(Regex_yread)
    ## DIFFERENCE Form (DIF) check for last y value of the line
    diff =false
    ##
    count = 0
    sumy = 0.0
    
    while $2.to_s != ""
      [ $3.to_i , 1].max.times {
        diff = $1=="x"
        y= $2.to_f # if 
        sumy =  ( !diff  &&  y ) || y + sumy.to_f # sumy.to_f needed if summy was ? and $1 is now x)
        
        iyline << sumy
        count += 1
      }
      $'.match(Regex_yread)
    end
    
    [iyline, count,diff]
  end

end