class SnippetsController < ApplicationController

  before_filter :authenticate_user!, :only=>[:mine, :edit, :update]

  def index
    opts = {:page => params[:page],:order=>'created_at DESC'}
    if params[:user_id]
      @info = "#{User.find(params[:user_id]).username}'s snippets"
      @snippets = Snippet.paginate_by_user_id params[:user_id], opts
    elsif params[:lang]
      @info = "Snippets in #{lang.capitalize}"
      @snippets = Snippet.paginate_by_language params[:lang], opts
    else
      @info = "Recent snippets"
      @snippets = Snippet.paginate opts 
    end
  end

  def show
    @snippet = Snippet.find params[:id]
    @sections = @snippet.get_sections
    @versions = @snippet.versions
  end

  def create
    @snippet = Snippet.new params[:snippet]
    @snippet.user = current_user
    if @snippet.save
      redirect_to @snippet
    else
      render :new
    end
  end

  def new
    @snippet = Snippet.new
  end

  def edit
  end

  def update
  end

  def diff
  end

  def mine 
    @snippets = current_user.snippets.find_all_by_private true
  end

end
