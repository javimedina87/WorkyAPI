class ApplicationController < ActionController::API

  #Method to check token on every http request
  def authenticate_request!
    unless token_validated?
      render json: { errors: ['Not Authenticated'] }, status: 401
      return
    end
  rescue JWT::VerificationError, JWT::ExpiredSignature, JWT::DecodeError
    render json: { errors: ['Token error'] }, status: 401
  end

  private
  #Check all below conditions
  def token_validated?
    http_token && decoded_token && compare_token_and_id_from_db
  end

  #Check if token is in header request
  def http_token
    @http_token ||= if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    end
  end

  #Decode token received from http request
  def decoded_token
    @decoded_token ||= JWT.decode http_token, Rails.application.secrets.token_key, true, { :algorithm => Rails.application.secrets.token_algorithm }
  end

  #Check token from database
  def compare_token_and_id_from_db
    @valid_token ||= User.where(id: user_id_from_token, token: http_token)
  end

  #Get id from token
  def user_id_from_token
    @user_id_from_token ||= decoded_token[0]["user_id"]
  end

  #Get username from token
  def user_name_from_token
    @user_name_from_token ||= decoded_token[0]["user_name"]
  end

  #Get expiration date from token
  def token_expiration_date
    @token_expiration_date ||= decoded_token[0]["exp"]
  end

end