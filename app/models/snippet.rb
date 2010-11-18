class Snippet < ActiveRecord::Base
  belongs_to :user
  LANGUAGES = Simplabs::Highlight::SUPPORTED_LANGUAGES
  DEFAULT_LANGUAGE = LANGUAGES[:ruby]
  before_save :set_language 

  def set_language 
    self.language = DEFAULT_LANGUAGE if self.language.blank?  
  end

  def author 
    return self.user.username || User::ANON 
  end

  def get_sections 
    
  end
end
