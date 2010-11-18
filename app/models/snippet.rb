class Snippet < ActiveRecord::Base
  belongs_to :user
  LANGUAGES = CodeRay::Scanners.list.sort
  LANGUAGES_HASH = {"html"=>:html,
                    "xml"=>:xml,
                    "htm"=>:html,
                    "mysql"=>:sql,
                    "yml"=>:yaml,
                    "php"=>:php,
                    "c"=>:c, 
                    "sql"=>:sql,
                    "css"=>:css,
                    "cpp"=>:cpp,
                    "c++"=>:cpp,
                    nil=>:plaintext,
                    "nitro_xhtml"=>:nitro_xhtml,
                    "java"=>:java,
                    "groovy"=>:groovy,
                    "txt"=>:plaintext,
                    "rb"=>:ruby,
                    "json"=>:json,
                    "python"=>:python,
                    "diff"=>:diff, 
                    "scheme"=>:scheme,
                    "yaml"=>:yaml,
                    "debug"=>:debug,
                    "delphi"=>:delphi,
                    "h"=>:c,
                    "ruby"=>:ruby,
                    "hpp"=>:cpp,
                    "js"=>:java_script, 
                    "xsd"=>:xml,
                    "py"=>:python,
                    "rhtml"=>:rhtml,
                    "erb"=>:rhtml}

  DEFAULT_LANGUAGE = "ruby" 
  before_save :set_language 
  
  has_paper_trail

  def set_language 
    self.language = DEFAULT_LANGUAGE if self.language.blank?  
  end

  def get_sections 
   #the shebanged lines are always one less than the gruops
   sep =
   shebanged_lines = self.content.scan(/^##!\s+([\w.]+).*\n/).flatten
   groups = self.content.split /^##!\s+\w+.*\n/
   default_hash =  [{:language=>self.language, :content=>self.content}]
   unless shebanged_lines.any? 
    return default_hash 
   end

   begin
        
       shebanged_lines.each_index.collect do |i|
         title, ft= shebanged_lines[i].scan(/(\w+)\.?(\w+)?/).flatten
         #swap if ft is nil
         title, ft = ft, title if ft.nil?
         {:language=>LANGUAGES_HASH[ft], :content=>groups[i+1], :title=>shebanged_lines[i]}
       end
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
