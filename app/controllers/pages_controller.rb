class PagesController < ApplicationController
	def index
		@upcoming_event = Community.joins(:room).where('rooms.isFinished = ? AND rooms.date not ? AND rooms.show_top_page = ?', false, nil, true).\
		select("communities.id AS community_id, rooms.name AS room_name, rooms.id AS room_id, rooms.date AS room_date, rooms.prize AS room_prize, communities.name AS community_name").\
		order("date").limit(20)
	end

	def user_index
		@own_communities = Community.joins(:community_administrator).where('community_administrators.user_id = ?', current_user.id)
		@joined_communities = Community.joins(:community_user_list).where(:community_user_lists => {user_id: current_user.id})
		@opened_communities = []

		@joined_communities.each do |community|
			rooms = Community.joins(:room).where('rooms.community_id = ? AND rooms.isFinished = ? AND rooms.date not ?',\
				community.id, false, nil).select("communities.name as community_name, communities.id, rooms.name, rooms.id as room_id, rooms.prize as prize, rooms.date as date").order("date")
			rooms.each do |room|
				@opened_communities.push(room)
			end

		end
		@joind_rooms = Room.joins(:room_user_list).where(:room_user_lists =>{user_id: current_user.id}, :rooms =>{isFinished: false})
		@opened_rooms = Room.where(user_id: current_user.id, isFinished: 'f')
	end
end

