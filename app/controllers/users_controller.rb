class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all

    begin
      decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
      binding.pry
    rescue JWT::ExpiredSignature
      # Handle expired token, e.g. logout user or deny access
    end

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  def hola
    render json: { message: "holaaaaa" }, status: 200
  end

  # Check user credentials
  def login
    user_name = params[:username]
    user_password = params[:password]
    user_attributes = User.where(username: user_name, password: user_password).pluck(:id, :username)

    if user_attributes.present?

      #Time to expire (20secs)
      exp = Time.now.to_i + 60
      exp_payload = { :data => 'data', :exp => exp }

      hmac_secret = 'my$ecretK3y'

# IMPORTANT: set nil as password parameter
      token = JWT.encode exp_payload, hmac_secret, 'HS256'

# Try decoded_token
      begin
        decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
      rescue JWT::ExpiredSignature
        # Handle expired token, e.g. logout user or deny access
      end

      render json: { JWT: token }, status: 200
    else
      render json: { error: "Invalid email or password" }, status: 400
    end
  end



  def jwt

    token = params[:token]


    # Try decoded_token
    begin
      decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }

    rescue JWT::ExpiredSignature
      # Handle expired token, e.g. logout user or deny access
      render json: { error: "token null" }, status: 400
    end

  end








  # Add new user
  def register
    user_name = params[:username]
    user_password = params[:password]
    user_email = params[:email]
    userIsUnique = User.where(username: user_name).or(User.where(email: user_email))
    binding.pry
    if !userIsUnique.present?
      user = User.new(username: user_name, password: user_password, email: user_email)
      user.save
      render json: { success: "User saved successfully" }, status: 200
    else
      render json: { error: "Username or email already exit" }, status: 409
    end
  end



end
