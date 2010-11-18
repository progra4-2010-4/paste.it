module ApplicationHelper
  def highlight_code(language, content, lines=-1) 
   CodeRay.scan(content.split("\n")[0..lines], language).div :line_numbers=>:table, :css => :class 
  end
end
