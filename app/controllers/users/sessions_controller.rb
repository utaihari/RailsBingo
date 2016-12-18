class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # skip_before_filter :store_location

  # GET /resource/sign_in
  def new
    @community_id = nil
    @room_id = nil
    @isDirectGame = false
    session[:dest_url] = pages_user_index_path
    if params[:community_id] != nil || params[:room_id] != nil
      @community_id = params[:community_id]
      @room_id = params[:room_id]
      session[:dest_url] = join_room_path(@community_id, @room_id)
      @isDirectGame = true
    end
    super
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end
  # def after_sign_in_path_for(resource)
  #   if (session[:previous_url] == root_path)
  #     super
  #   else
  #     session[:previous_url] || root_path
  #   end
  # end
  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :detail])
  end
end
