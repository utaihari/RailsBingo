require "securerandom"

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
    @community_id = nil
    @room_id = nil
    @isGuest = false
    @isDirectGame = false

    if params[:community_id] != nil || params[:room_id] != nil || params[:isGuest] != nil
      @community_id = params[:community_id]
      @room_id = params[:room_id]
      @isGuest = params[:isGuest] == 1
      @mail_address = SecureRandom.hex(4) + "@guest.com"
      @password = "GuestPassword"
      @isDirectGame = true
    end
  end

  # POST /resource
  def create
    super
    if params[:community_id] != nil || params[:room_id] != nil
      if params[:isGuest] != nil
        if params[:isGuest] == 1
          guest = User.find_by(id:current_user.id)
          guest.isGuest = true
          guest.save
        end
      end
      redirect_to controller: 'rooms', action: 'join', community_id: params[:community_id], room_id: params[:room_id] and return
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

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

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
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
