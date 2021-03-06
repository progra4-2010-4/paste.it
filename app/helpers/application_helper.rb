module ApplicationHelper
  def highlight_code(language, content, lines=-1) 
    if lines != -1
      CodeRay.scan(content.split("\n")[0..lines], language).div :line_numbers=>:table, :css => :class
    else
      CodeRay.scan(content, language).div :line_numbers=>:table, :css => :class 
    end
  end

  def diff_class(id, current, original)
    case id
      when current.to_i then "current"
      when original.to_i then "original"
      else ""
    end
  end
  
  def diff_member?(id, current, original)
    id == current.to_i || id == original.to_i
  end
end
