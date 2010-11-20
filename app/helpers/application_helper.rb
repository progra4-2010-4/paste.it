module ApplicationHelper
  def highlight_code(language, content, lines=-1) 
    if lines != -1
      CodeRay.scan(content.split("\n")[0..lines], language).div :line_numbers=>:table, :css => :class
    else
      CodeRay.scan(content, language).div :line_numbers=>:table, :css => :class 
    end
  end

  def diff_class(id, current, original) 
    r= ""
    if current && original
      r = id==current.to_i ? "current" : "original"
    end
    r
  end
  
  def diff_member?(id) end
end
