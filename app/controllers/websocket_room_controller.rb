class WebsocketRoomController < WebsocketRails::BaseController
	def add_number
		recieve_message = message()
		WebsocketRails["#{recieve_message[:room_id]}"].trigger(:websocket_add_number, recieve_message[:number])
	end

	def change_room_condition
		recieve_message = message()
		if recieve_message[:condition].to_i = 1
			WebsocketRails["#{recieve_message[:room_id]}"].trigger(:change_room_condition, 1)
		elsif recieve_message[:condition].to_i = 2
			WebsocketRails["#{recieve_message[:room_id]}"].trigger(:change_room_condition, 2)
		end
	end

	def add_notice
		recieve_message = message()
		WebsocketRails["#{recieve_message[:room_id]}"].trigger(:add_notice, recieve_message[:notice])
	end
end
