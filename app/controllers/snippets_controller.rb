class SnippetsController < ApplicationController

  before_filter :authenticate_user!, :only=>[:my, :edit, :update]

  def index
    if params[:user_id]
      @info = "#{User.find(params[:user_id]).username}'s snippets"
      q = Snippet.find_all_by_user_id_and_private params[:user_id], false, :order=>'created_at DESC' 
    elsif params[:lang]
      @info = "Snippets in #{params[:lang].capitalize}"
      q = Snippet.find_all_by_language_and_private params[:lang], false, :order=>'created_at DESC'
    else
      @info = "Recent snippets"
      q = Snippet.find_all_by_private(false, :order=>'created_at DESC')
    end
    @snippets = q.paginate :page=>params[:page], :per_page=>10
  end

  def show
    @snippet = Snippet.find params[:id]
    if @snippet.private
      redirect_to root_path unless user_signed_in? && current_user == @snippet.user
    end
    @current = @snippet.versions.first.id
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
    @snippet = Snippet.find params[:id]
    redirect_to root_path unless current_user == @snippet.user
  end

  def update
    @snippet = Snippet.find params[:id]
    redirect_to root_path unless current_user == @snippet.user
    if @snippet.update_attributes params[:snippet]
      redirect_to @snippet
    else
      render :edit
    end
  end

  def my 
    @snippets = current_user.snippets.order("created_at DESC").paginate :page=>params[:page]
    render :index
  end

end
