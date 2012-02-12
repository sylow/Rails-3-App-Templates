class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
    render :layout => false
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    #success = @user_session.save
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to root_path
  end
end
