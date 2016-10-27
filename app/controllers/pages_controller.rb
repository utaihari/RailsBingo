class PagesController < ApplicationController
  def index
  end

  def user_index
  	@own_communities = Community.where(user_id: current_user.id)
  end
end
