class VersionsController < ApplicationController
  def show
    @snippet = Version.find(params[:id]).reify || Snippet.find(params[:snippet_id])
    @sections = @snippet.get_sections
    @versions = @snippet.versions
    #original = Snippet.find params[:snippet_id]
    #@diff = Differ.diff current, original
    render 'snippets/show'
  end

  def compare
    p params
  end

end
