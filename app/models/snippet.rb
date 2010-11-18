class Snippet < ActiveRecord::Base
  belongs_to :user
  LANGUAGES = CodeRay::Scanners.list.sort 
  DEFAULT_LANGUAGE = "ruby" 
  before_save :set_language 
  
  has_paper_trail

  def set_language 
    self.language = DEFAULT_LANGUAGE if self.language.blank?  
  end

  def get_sections 
   #the shebanged lines are always one less than the gruops
   sep =
   shebanged_lines = self.content.scan(/^##!\s+(\w+).*\n/).flatten
   groups = self.content.split /^##!\s+\w+.*\n/
   default_hash =  [{:language=>self.language, :content=>self.content}]
   unless shebanged_lines.any? 
    return default_hash 
   end

   begin
       shebanged_lines.each_index.collect{|i| {:language=>shebanged_lines[i], :content=>groups[i+1]}}
   rescue
     return default_hash
   end
  end

  def diff(current, original) 
    c = current.zero?  || current >= self.versions.size  ? self :  self.versions[current].reify 
    o = original.zero? || original >= self.versions.size ? self :  self.versions[original].reify 
    Differ.diff(c.content, o.content).format_as(:html)
  end
end
