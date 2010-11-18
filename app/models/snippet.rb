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

  def self.diff(current, original) 
    Differ.diff(current.content, original.content).format_as(:html)
  end
end
