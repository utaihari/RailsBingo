class PagesController < ApplicationController
  def index
  end

  def user_index
  	@own_communities = Community.where(user_id: current_user.id)
  	@joined_communities = Community.joins(:community_user_lists).where(:community_user_lists => {user_id: current_user.id})
  	@opened_communities = @joined_communities.joins(:room).where(isFinished:false)
  end
end
