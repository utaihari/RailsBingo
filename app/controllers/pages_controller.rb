class PagesController < ApplicationController
	def index
	end

	def user_index
		@own_communities = Community.where(user_id: current_user.id)
		@joined_communities = Community.joins(:community_user_lists).where(:community_user_lists => {user_id: current_user.id})
		@opened_communities = []

		@joined_communities.each do |community|
			rooms = Community.joins(:rooms).where('rooms.community_id = ? AND rooms.isFinished =\'f\'', community.id).select("communities.name as community_name, communities.id, rooms.name")
			rooms.each do |room|
				@opened_communities.push(room)
			end

		end
	end
end

