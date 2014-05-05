def f_log(str="\n",n=1)
  if Jcampdx.class_eval("@@logging")
    file =  Jcampdx.class_eval("@@log_path")
    path= __FILE__.to_s.gsub(/kaitatari\/log.rb/,"")
    ofile=File.open(file, 'a+')
    if str
      ofile.write "#{caller(0)[1..n].to_s.gsub(/#{path}/,"")} : #{str} \n"
    else
      ofile.write "\n\n#{"#"*30}Kia ora!#{"#"*30}\n#{Time.now.to_s}\n initialize #{caller(0)[2..-1]}\n\n"
    end
  ofile.close
  end
  true if str
end