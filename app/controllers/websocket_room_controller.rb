class WebsocketRoomController < WebsocketRails::BaseController
	def add_number
		recieve_message = message()

		@room = Room.joins(:community).joins(:user).find(recieve_message[:room_id])

		if recieve_message[:number] == nil
			return
		end

		number = recieve_message[:number].to_i

		if @room == nil || number < 1 || 75 < number
			return
		end

		if isRoomOrganizer(recieve_message[:room_id])
			RoomNumber.create(room_id: recieve_message[:room_id],number: recieve_message[:number])
			rates = @room.rates.split(",")
			@room.pre_rate = rates[number-1]
			rates[number-1] = 0
			@room.rates = rates.join(",")
			@room.times += 1
			@room.save

			auto_cards = BingoCard.includes(:user).includes(:room).where(room_id: recieve_message[:room_id], is_auto: true)

			auto_cards.each do |card|
				card_numbers = card.numbers.split(",")
				card_checks = card.checks.split(",")
				card_numbers.each_with_index do |num, i|
					if num.to_i == number
						card_checks[i] = "t"
						card.holes += 1

						if !card.done_bingo
							riichi_lines = card.riichi_lines
							card.riichi_lines = calc_riichi_lines(card_checks)

							if riichi_lines != card.riichi_lines
								notice = "リーチ！（自動機能により登録されました）"
								user = User.find(card.user_id)
								RoomNotice.create!(room_id: recieve_message[:room_id], user_name: user.name, notice: notice, color: "magenta")
							end

							if check_bingo(card_checks)
								user = User.find(card.user_id)
								notice = "ビンゴ！（自動機能により登録されました）"
								RoomNotice.create!(room_id: recieve_message[:room_id], user_name: user.name, notice: notice, color: "red")
								card.bingo_lines += 1
								card.done_bingo = true
								BingoUser.create(room_id: recieve_message[:room_id], user_id: user.id, times: @room.times, seconds: 0, note:"自動ユーザー")
							end
						end
						card.checks = card_checks.join(",")

					end
				end
				card.save
			end
			WebsocketRails["#{recieve_message[:room_id]}"].trigger(:websocket_add_number, recieve_message[:number])
		end
	end

	def change_room_condition
		recieve_message = message()
		if recieve_message[:condition].to_i = 1
			start_game(recieve_message[:room_id].to_i)
			WebsocketRails["#{recieve_message[:room_id]}"].trigger(:change_room_condition, 1)
		elsif recieve_message[:condition].to_i = 2
			end_game(recieve_message[:room_id].to_i)
			WebsocketRails["#{recieve_message[:room_id]}"].trigger(:change_room_condition, 2)
		end
	end

	def add_notice
		recieve_message = message()
		user_name = recieve_message[:user_name] != nil ? recieve_message[:user_name] : current_user.name
		color = recieve_message[:color] != nil ? recieve_message[:color] : "black"
		RoomNotice.create(room_id: recieve_message[:room_id], user_name: user_name, notice: recieve_message[:notice], color: color)
		WebsocketRails["#{recieve_message[:room_id]}"].trigger(:add_notice, recieve_message)
	end

	private

	def start_game(room_id)
		@room = Room.joins(:community).joins(:user).find(room_id)
		if @room == nil
			return
		end
		@room.isPlaying = true
		@room.save

		RoomNumber.create(room_id: room_id, number: -1)
		auto_cards = BingoCard.where(room_id: room_id, is_auto: true)
		auto_cards.each do |card|
			card_numbers = card.numbers.split(",")
			card_checks = card.checks.split(",")
			card_numbers.each_with_index do |num, i|
				if num.to_i == -1
					card_checks[i] = "t"
					card.checks = card_checks.join(",")
					card.holes += 1
				end
			end
			card.save
		end
	end

	def end_game(room_id)
		@room = Room.joins(:community).joins(:user).find_by(id: room_id)
		if !isRoomOrganizer(room_id)
			render :text => "主催者ではありません"
		end
		@bingo_list = BingoUser.joins(:user).where(room_id: room_id).order("bingo_users.times ASC, bingo_users.seconds ASC").select("seconds","times","name","email","user_id","note")
		@room.isFinished = true
		@room.save
		@number_of_joined = RoomUserList.where(room_id: room_id).count
		if !@room.can_bring_item
			UserItemList.delete_all(room_id: @room.id, temp: true)
		end
	end



	def check_bingo(checks)
	    # Alignment bingocard sequence
	    # 0  1  2  3  4
	    # 5  6  7  8  9
	    # 10 11 12 13 14
	    # 15 16 17 18 19
	    # 20 21 22 23 24

	    #check horizontal line
	    for i in 0..4
	    	if checks[i*5+0] == "t" && checks[i*5+1] == "t" && checks[i*5+2] == "t" && checks[i*5+3] == "t" && checks[i*5+4] == "t"
	    		return true
	    	end
	    end
    	#check vertical line
    	for i in 0..4
    		if checks[i+0] == "t" && checks[i+5] == "t" && checks[i+10] == "t" && checks[i+15] == "t" && checks[i+20] == "t"
    			return true
    		end
    	end
    	#check diagonal line
    	if checks[0] == "t" && checks[6] == "t" && checks[12] == "t" && checks[18] == "t" && checks[24] == "t"
    		return true
    	end
    	if checks[4] == "t" && checks[8] == "t" && checks[12] == "t" && checks[16] == "t" && checks[20] == "t"
    		return true
    	end
    	return false
    end

    def calc_riichi_lines(checks)
    	holes = []
    	number_of_one_left_line = 0
    	for check in checks
    		if check == "t"
    			holes.push(1)
    		else
    			holes.push(0)
    		end
    	end
    	for i in 0..4
    		if (holes[i*5+0]+holes[i*5+1]+holes[i*5+2]+holes[i*5+3]+holes[i*5+4]) == 4
    			number_of_one_left_line += 1
    		end
    	end
    	for i in 0..4
    		if (holes[i+0]+holes[i+5]+holes[i+10]+holes[i+15]+holes[i+20]) == 4
    			number_of_one_left_line += 1
    		end
    	end
    	if (holes[0]+holes[6]+holes[12]+holes[18]+holes[24]) == 4
    		number_of_one_left_line += 1
    	end
    	if (holes[4]+holes[8]+holes[12]+holes[16]+holes[20]) == 4
    		number_of_one_left_line += 1
    	end
    	return number_of_one_left_line
    end


    def set_room
    	@room = Room.find(params[:id])
    	@community = Community.find(params[:community_id])
    end


    def isRoomOrganizer(room_id)
    	return current_user.id == Room.find_by(id:room_id).user_id
    end
    def isCommunityMember(community_id)
    	return CommunityUserList.exists?(community_id:community_id, user_id: current_user.id)
    end
    def isRoomMember(room_id)
    	return RoomUserList.exists?(room_id: room_id, user_id: current_user.id)
    end
    def isRoomMember(room_id,user_id)
    	return RoomUserList.exists?(room_id: room_id, user_id: user_id)
    end
end
