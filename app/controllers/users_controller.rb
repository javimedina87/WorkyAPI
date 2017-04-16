class UsersController < ApplicationController

  before_action :authenticate_request!, :except => [:login, :register]

  #TODO delete this method
  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # Check user credentials
  def login
    user = User.find_by_email(params[:email])

    if user.present? && validate_password(user)
      #Create token for logged user
      expiration = Time.now.to_i + 600
      payload = { user_id: user.id, user_name: user.username, exp: expiration }
      token = JWT.encode payload, Rails.application.secrets.token_key, Rails.application.secrets.token_algorithm, header_fields={hola:'epas'}

      #Save new token for logged user
      User.find_by_id(user.id).update(token: token)
      render json: { JWT: token }, status: 200
    else
      render json: { error: 'Invalid email or password' }, status: 400
    end
  end

  # Add new user to database, email must be unique
  def register
    email_is_unique = User.find_by_email(params[:email])

    if !email_is_unique.present?

      #Create user in database
      user = User.new(username: params[:username], password: encrypt_password, email: params[:email])
      user.save

      #Create token for new user having id
      expiration = Time.now.to_i + 600
      payload = { user_id: user.id, user_name: user.username, exp: expiration }
      token = JWT.encode payload, Rails.application.secrets.token_key, Rails.application.secrets.token_algorithm

      #Save first token for registered user
      User.find_by_id(user.id).update(token: token)

      render json: { JWT: token }, status: 200
    else
      render json: { error: 'Email already exists' }, status: 409
    end
  end

  private
  #Encrypt password for new user
  def encrypt_password
    verifier = ActiveSupport::MessageVerifier.new Rails.application.secrets.password_key
    verifier.generate params[:password]
  end

  #Check user password from database and form
  def validate_password(user)
    verifier = ActiveSupport::MessageVerifier.new Rails.application.secrets.password_key
    db_password = verifier.verify(user.password)
    db_password == params[:password]
  end

end