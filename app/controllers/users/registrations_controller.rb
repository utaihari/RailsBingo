require "securerandom"

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  FROM_JOIN_ROOM = 0
  FROM_TOP_PAGE = 1

  # skip_before_filter :store_location

  # GET /resource/sign_up
  def new
    @community_id = nil
    @room_id = nil
    @isGuest = false
    @source = -1

    if params[:source] != nil
      if params[:source].to_i == FROM_TOP_PAGE
        @source = FROM_TOP_PAGE
        @isGuest = true
        @mail_address = SecureRandom.hex(4) + "@guest.com"
        @password = "GuestPassword"
      end

      if params[:source].to_i == FROM_JOIN_ROOM
        @source = FROM_JOIN_ROOM
        @community_id = params[:community_id]
        @room_id = params[:room_id]
        @isGuest = params[:isGuest].to_i == 1
        @mail_address = SecureRandom.hex(4) + "@guest.com"
        @password = "GuestPassword"
        session[:dest_url] = join_room_path(@community_id, @room_id)
      end
    else
      session[:dest_url] = pages_user_index_path
    end
    super
  end

  # POST /resource
  def create
    if params[:room][:direct] != nil && params[:room][:direct] == 't'
      @community = Community.find(0)
      number_rate = Array.new(75,10)
      @room = @community.room.build(user_id: 0, community_id: 0, name: params[:room][:name], AllowGuest: true, rates:number_rate.join(","))
      @room.save
      session[:dest_url] = community_room_path(0, @room.id)
    end
    super
    if params[:user][:isGuest] == 't'
      guest = User.find_by(id:current_user.id)
      guest.isGuest = true
      guest.save
    end
    if params[:room][:direct] != nil && params[:room][:direct] == 't'
      @room.user_id = current_user.id
      @room.save
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
    params.require(:room).permit(:name)
    params.require(:room).permit(:direct)
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
