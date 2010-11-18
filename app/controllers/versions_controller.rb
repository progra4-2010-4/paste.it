class VersionsController < ApplicationController
  def show
    v = Version.find(params[:id])
    @snippet = v.reify
    return redirect_to snippet_path(Snippet.find(params[:snippet_id])) if @snippet.nil?
    @sections = @snippet.get_sections
    @versions = @snippet.versions
    #original = Snippet.find params[:snippet_id]
    #@diff = Differ.diff current, original
    render 'snippets/show'
  end

  def compare
    c, o = params[:versions]
    @snippet = Snippet.find params[:snippet_id]
    if Version.exists?(:id=>c) && Version.exists?(:id=>o) 
      raw_current  = Version.find(c)
      raw_original = Version.find(o)
      #only allow valid comparisons
      return redirect_to snippet_path(@snippet) if raw_current.item_id != @snippet.id || raw_original.item_id != @snippet.id

      #do the actual comparison
      current = raw_current.reify || @snippet
      original = raw_original.reify || @snippet

      @diff = Differ.diff(current.content, original.content).format_as :html
      @current  = c
      @original = o
      @versions = @snippet.versions
      render 'snippets/show'
    else
      redirect_to snippet_path @snippet
    end
  end

end
