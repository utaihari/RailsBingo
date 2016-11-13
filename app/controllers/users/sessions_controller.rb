class Users::SessionsController < Devise::SessionsController
before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
    @community_id = nil
    @room_id = nil
    @isDirectGame = false

    if params[:community_id] != nil || params[:room_id] != nil
      @community_id = params[:community_id]
      @room_id = params[:room_id]
      @isDirectGame = true
    end
  end

  # POST /resource/sign_in
  def create
    super
    if params[:community_id] != nil || params[:room_id] != nil
      redirect_to controller: 'rooms', action: 'join', community_id: params[:community_id], room_id: params[:room_id] and return
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :detail])
  end
end
