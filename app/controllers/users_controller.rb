class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
  
  def create
    auth_hash = request.env["omniauth.auth"]
    # raise
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.name}"
    else
      puts "I'm making a new user"
      # User doesn't match anything in the DB
      # TODO: Attempt to create a new user
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.name}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not create new user account"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end
    
    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    return redirect_to root_path
  end
  
  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    
    redirect_to root_path
  end
  
  
end
