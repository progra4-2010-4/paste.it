class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  private
    def record_not_found 
     redirect_to root_path 
    end
end
