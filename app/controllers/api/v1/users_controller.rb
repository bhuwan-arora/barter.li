class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:update, :show, :get_share_token, :generate_share_token,
    :set_user_preferred_location, :user_preferred_location]
  
  # GET '/user_profile'
  def user_profile
    user  = User.find(params[:id])
    setting = user.settings.find_by(name: "location")
    location = setting.present? ? Location.find(setting.value) : false 
    render :json => {user: user, books: user.books}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET '/current_user_profile'
  def show
    user  = current_user
    render :json => {user: user, books: user.books}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  def update
    user  = current_user
    if(user.update_attributes(user_params))
      render json: {status: :success, user: user}
    else
      render json: {status: :error}
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  def get_profile_image
    image_url = User.find(params[:id]).image.url
    render json: {image_url: image_url, status: :success}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST /prefered_location
  def set_user_preferred_location
    location = current_user.set_preferred_location(params)
      if location
        render :json => location 
      else
        render :json => {error_code: Code[:error_resource], error_message: "location not created"}, status: Code[:status_error]
      end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end 

  # GET /prefered_location
  def get_user_preferred_location
    location = current_user.preferred_location
    if(location)
      render json: location
    else
      render json: {location: nil}
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end
 
  def generate_share_token
    token = current_user.generate_share_token
    render :json => {share_token: token}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  def get_share_token
    token = current_user.share_token 
    render :json => {share_token: token}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

 private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :description, :email, :profile
      )
    end
end