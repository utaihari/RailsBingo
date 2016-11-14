class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # def after_sign_in_path_for(resource)
  #   pages_user_index_url
  # end

end
