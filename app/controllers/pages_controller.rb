class PagesController < ApplicationController
	def index
	end

	def user_index
		@own_communities = Community.joins(:community_administrator).where('community_administrators.user_id = ?', current_user.id)
		@joined_communities = Community.joins(:community_user_list).where(:community_user_lists => {user_id: current_user.id})
		@opened_communities = []

		@joined_communities.each do |community|
			rooms = Community.joins(:room).where('rooms.community_id = ? AND rooms.isFinished = ?', community.id, false).select("communities.name as community_name, communities.id, rooms.name")
			rooms.each do |room|
				@opened_communities.push(room)
			end

		end
		@joind_rooms = Room.joins(:room_user_list).where(:room_user_lists =>{user_id: current_user.id}, :rooms =>{isFinished: false})
		@opened_rooms = Room.where(user_id: current_user.id, isFinished: 'f')
	end
end

