require 'test_helper'

class SnippetTest < ActiveSupport::TestCase

  test "snippet is saved" do 
    assert Snippet.new(:content=>"puts %{hola mundo}", :language=>"ruby", :user=>users(:one), :private=>true)
  end

  test "snippet is saved non private by default" do 

    s = Snippet.new :content=>"while(1){printf('hola')}", :language=>"c", :user=>users(:one)

    assert s.save
    assert_equal false, s.private
  end

  test "snippet has an anonymous author by default" do

    s = Snippet.new :content=>"while(1){printf('hola')}", :language=>"c" 

    assert s.save
    assert_nil s.user
  end

  test "snippet is stored with the default language" do 
    s = Snippet.new :content=>"print 'hola mundo'", :user=>users(:one)

    assert s.save
    assert_equal Snippet::DEFAULT_LANGUAGE, s.language
  end

  test "snippet is split into sections with shebang syntax" do 

    #la sintaxis #shebang: una línea con un octothorpe+shebang (##!), uno O MAS espacios, y el nombre de un lenguaje soportado
    #seguido de lo que sea, se debería ignorar

    #PRUEBA 1: reconoce secciones con #shebang, a pesar del espacio en blanco
    content ="##!   ruby\nputs %{o hai}\n##! html   \n <h1>OH, HAI</h1>"
    s = Snippet.new :content=>content, :language=>"ruby", :user=>users(:two)
    
    assert s.save
    sections = s.get_sections
    assert_equal 2, sections.size
    assert_instance_of Array, sections
    assert_instance_of Hash, sections.first

    #debe producir un arreglo de hashes de la forma
    #[{:language=>"ruby", :content=>"puts %{o hai}"}, {:language=>"html", :content=>"<h1>OH HAI</h1>"}
    assert_equal "ruby", sections.first[:language]
    assert_equal "html",  sections.last[:language]
    
    #la línea de shebang NO tiene que estar en el contenido final
    assert_nil sections.first[:content]["#! ruby"]
    assert_nil sections.last[:content]["#! html"]

    #tiene que haber encontrado el contenido bien
    assert_not_nil sections.first[:content]["puts %{o hai}"]
    assert_not_nil sections.last[:content]["<h1>OH, HAI</h1>"]
    
    #PRUEBA 2:
    #shebang tiene precedencia sobre el lenguaje original al seccionar (pero no al guardar)
    t = Snippet.new :content=>"##! java\nnew Map(){{put('mind', 'blown')}};", :language=>"yaml"
    
    sections = t.get_sections
    assert t.save
    assert_equal "yaml", t.language
    assert_equal 1, sections.size
    assert_equal "java", sections.first[:language]
    assert_not_nil sections.first[:content]["'mind', 'blown'"]
    
    #PRUEBA 3: 
    #no debería partir en secciones si hay un shebang en medio de una línea:
    r = Snippet.new :content=>"and you write it like this: `##! python` and baam!", :language=>"ocaml"
    
    #si sólo hay una sección, retornar el snippet original:
    sections = r.get_sections
    assert_equal 1, sections.size
    assert_equal "ocaml", sections.first[:language]
    #como no es un verdadero #shebang, no debería quitarse:
    assert_not_nil sections.first[:content]["##! python` and"]
    
    #sólo el primero debería se considerado
    r = Snippet.new :content => "##! python ocaml c, as\n print[ e for e in range(10)]", :language=>"js"

    sections = r.get_sections
    assert_equal 1, sections.size
    assert_equal "python", sections.first[:language]
  end

  test "snippet is versioned" do
    #A HISTORY IS STORED FOR THE SNIPPET
    #cf: https://github.com/airblade/paper_trail

    snippet = Snippet.create :content=>"int main(){\nprintf('hallo, welt!')\n}"

    assert_not_nil snippet.versions
    assert_not_nil snippet.versions.last
    assert_nil snippet.versions.last.reify

    #change it:
    snippet.update_attributes :content=> "public static void main(String[] args){/**/}"

    assert_equal 2, snippet.versions.size
    
    #TEST SNIPPET VERSIONS ARE DIFFABLE
    #cf: https://github.com/pvande/differ
    snippet = Snippet.create :content=>"int main(){\nprintf('hallo, welt!')\n}"
    snippet.update_attributes :content=> "public static void main(String[] args){\nprintf('hallo, welt!')\n}"
    snippet.update_attributes :content=> "(println 'hallo welt')"
    assert_equal 3, snippet.versions.size

    #el arreglo snippet.versions no tiene un elemento 0. De modo que tanto el tamaño (un índice que tampoco existe)
    #como el 0 deberían referirse a la versión actual (es decir, a snippet y no a snippet.versions[n]

    assert_equal "<del class=\"differ\">public static void main(String[] args){\nprintf('hallo, welt!')\n}</del><ins class=\"differ\">(println 'hallo welt')</ins>",
      snippet.diff(0, 2)

    assert_equal "<del class=\"differ\">public static void main(String[] args){\nprintf('hallo, welt!')\n}</del><ins class=\"differ\">(println 'hallo welt')</ins>",
      snippet.diff(3, 2)


    snippet = snippet.previous_version 
    assert_equal "<del class=\"differ\">int main(){</del><ins class=\"differ\">public static void main(String[] args){</ins>\nprintf('hallo, welt!')\n}",
      snippet.diff(2, 1)
  end
end
