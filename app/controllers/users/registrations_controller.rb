require "securerandom"

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  skip_before_filter :store_location

  def direct_create_room
    


  # GET /resource/sign_up
  def new
    @community_id = nil
    @room_id = nil
    @isGuest = false
    @isDirectGame = false

    if params[:community_id] != nil || params[:room_id] != nil || params[:isGuest] != nil
      @community_id = params[:community_id]
      @room_id = params[:room_id]
      @isGuest = Integer(params[:isGuest]) == 1
      @mail_address = SecureRandom.hex(4) + "@guest.com"
      @password = "GuestPassword"
      @isDirectGame = true
      session[:dest_url] = join_room_path(@community_id, @room_id)
    end
    super
  end

  # POST /resource
  def create
    super
      if params[:user][:isGuest] == 't'
          guest = User.find_by(id:current_user.id)
          guest.isGuest = true
          guest.save
      end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
    user = User.find(current_user.id)
    user.isGuest = false
    user.save
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :detail])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :detail])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
