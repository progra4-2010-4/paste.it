class Snippet < ActiveRecord::Base
  belongs_to :user
  LANGUAGES = Simplabs::Highlight::SUPPORTED_LANGUAGES
  DEFAULT_LANGUAGE = LANGUAGES[:ruby]
  before_save :set_language 
  
  has_paper_trail

  def set_language 
    self.language = DEFAULT_LANGUAGE if self.language.blank?  
  end

  def get_sections 
    
  end

  def diff(current, original) 
    c = current.zero?  || current >= self.versions.size  ? self :  self.versions[current].reify 
    o = original.zero? || original >= self.versions.size ? self :  self.versions[original].reify 
    Differ.diff(c.content, o.content).format_as(:html)
  end
end
