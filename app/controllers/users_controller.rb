class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # Check user credentials
  def login
    user_name = params[:username]
    user_password = params[:password]
    user_id = User.where(username: user_name, password: user_password).pluck(:id)

    if user_id.present?
      render json: user_id, status: 200
    else
      render json: { error: "Invalid email or password" }, status: 400
    end
  end

  # Add new user
  def register
    user_name = params[:username]
    user_password = params[:password]
    uniqueUser = User.find_by(username: user_name)

    if !uniqueUser.present?
      user = User.new(username: user_name, password: user_password)
      user.save
      render json: { success: "User saved successfully" }, status: 200
    else
      render json: { error: "That username already exits" }, status: 409
    end
  end



end
