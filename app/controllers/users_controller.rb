class UsersController < ApplicationController
	before_filter :require_login, :only => :secret

	def index
		
	end
	
  def new
  	@user = User.new
  end

  def create
  	@user = User.new params[:user]
  	if @user.save
  		redirect_to root_url, notice: "Signed Up!"
  	else
  		render :new
  	end
  end

  def secret
  	
  end

  def status
    email = params[:email]
    # search for it
  	render json: {:registered => true}
  end

end
