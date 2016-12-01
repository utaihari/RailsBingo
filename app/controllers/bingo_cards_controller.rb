# coding: utf-8

class BingoCardsController < ApplicationController
	def show
		@community = Community.find(params[:community_id])
		@room = Room.find(params[:room_id])
		numberlist = BingoCard.find_by(user_id: current_user.id, room_id: params[:room_id])
		if numberlist == nil
			redirect_to community_path(params[:community_id]) and return
		end

		@numbers = []
		numbers = numberlist.numbers.split(",")
		numbers.each{|n|
			@numbers << n.to_i
		}
		@checks = numberlist.checks.split(",")
		@card = BingoCard.find(params[:id])
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id]).select("items.name, items.AllowUseDuringGame, items.id, quantity")
	end

	def create
		@bingo_card = BingoCard.find_by(room_id: params[:room_id], user_id: current_user.id)
		if @bingo_card != nil
			redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@bingo_card.id) and return
		end

		@numbers = make_bingo_num()
		@checks =[]
		25.times { |n|
			@checks << "f"
		}

		@bingo_card = BingoCard.create!(room_id:params[:room_id],user_id:current_user.id,numbers: @numbers.join(","),checks: @checks.join(","))
		redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@bingo_card.id)
	end

	def result
		bingo_users = BingoUser.where(params[:room_id]).order("BingoUser.times ASC, BingoUser.seconds ASC")
		@ranking = 0
		bingo_users.each_with_index do |user, i|
			if user.id == current_user.id
				@ranking = i+1
			end
		end
	end

	def tool_others_card
		@room = Room.find(params[:room_id])
		numberlist = BingoCard.find_by(id: params[:card_id])

		@numbers = []
		numbers = numberlist.numbers.split(",")
		numbers.each{|n|
			@numbers << n.to_i
		}
		@checks = numberlist.checks.split(",")
		@card = BingoCard.find(params[:card_id])
		user_name = User.find(params[:user_id]).name
		render :partial => "others-card", :locals => {user_name: user_name,  room: @room, card: @card, numbers: @numbers, checks: @checks }, :layout => false and return
	end

	def items
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id]).select("items.name, items.AllowUseDuringGame, items.id, quantity")
		@room = Room.find(params[:room_id])
	end

	def make_bingo_num
		numbers =[]
		random = Random.new

		b_numbers = []
		i_numbers = []
		n_numbers = []
		g_numbers = []
		o_numbers = []

		5.times do
			while true
				i = random.rand(1..15)
				if !b_numbers.include?(i) then
					b_numbers << i
					numbers << i
					break
				end
			end
			while true
				i = random.rand(16..30)
				if !i_numbers.include?(i) then
					i_numbers << i
					numbers << i
					break
				end
			end
			while true
				if n_numbers.length() == 2
					n_numbers << -1
					numbers << -1
					break
				end
				i = random.rand(31..45)
				if !n_numbers.include?(i) then
					n_numbers << i
					numbers << i
					break
				end
			end
			while true
				i = random.rand(46..60)
				if !g_numbers.include?(i) then
					g_numbers << i
					numbers << i
					break
				end
			end
			while true
				i = random.rand(61..75)
				if !o_numbers.include?(i) then
					o_numbers << i
					numbers << i
					break
				end
			end
		end
		return numbers
	end

	def check_number
		if params[:card_id] == nil
			return
		end
		card = BingoCard.find_by(id:params[:card_id])
		if card == nil || params[:index] == nil
			return
		end
		index = Integer(params[:index])

		if index < 0 || 24 < index
			return
		end

		checks = card.checks.split(",")

		if checks[index] == "t"
			checks[index] = "f"
		else
			checks[index] = "t"
		end

		card.checks = checks.join(",")
		if card.save
			render :json => checks
		else
			render :json => 0
		end
	end

	def check_items
		items = UserItemList.where(community_id: params[:community_id], user_id: current_user.id)
		render :json => items
	end

	def use_item
		community = Community.find(params[:community_id])
		item = Item.find(params[:item_id])

		user_item = UserItemList.find_by(user_id: current_user.id, community_id: community.id, item_id: item.id)

		if room.isPlaying && item.AllowUseDuringGame != 't'
			render :json => "error"
		end

		if user_item == nil
			render :json => "error"
		end

		quantity = user_item.quantity
		if quantity == 1
			user_item.destroy
		else
			user_item.quantity -= 1
			user_item.save
		end

		case item.type
		when 0
			increase_rate_random_num(room_id, card.effect)
		when 1
			increase_rate(room_id, card.effect, params[:number])
		when 2
			add_free(room_id)
		end
	end

	def increase_rate_random_num(room_id, effect)
		card = BingoCard.find_by(user_id:current_user.id, room_id:room_id)
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f'
				numbers_unchecked.push(number)
			end
		end

		selected_num = numbers_unchecked[rand(numbers_unchecked.length())]
		increase_rate(room_id, effect, selected_num)
	end
	def increase_rate(room_id, effect, number)
		room = Room.find(room_id)
		rates = room.rates.split(',')

		rate_size = 0.0
		rates.each do |rate|
			rate_size += Integer(rate)
		end

		increase = rate_size.to_f * Float(effect)
		rates[Integer(number)-1] = Integer(rates[Integer(number)-1]) + increase

		room.rates = rates.join(',')
		room.save
	end
	def add_free(room_id)
		card = BingoCard.find_by(user_id:current_user.id, room_id:room_id)
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f'
				numbers_unchecked.push(number)
			end
		end

		selected_num = numbers_unchecked[rand(numbers_unchecked.length())]
		numbers.each_with_index do |number,index|
			if number == selected_num
				numbers[index] = -1
			end
		end
		card.numbers = numbers.join(',')
		card.save
	end

	def get_checked_number
		if params[:room_id] == nil
			render :json =>[] and return
		end
		card = BingoCard.find_by(user_id:current_user.id,room_id:params[:room_id])
		if card == nil
			return
		end
		checks = card.checks.split(",")

		render :json => checks
	end

	def done_bingo
		if params[:room_id] == nil || params[:times] == nil || params[:seconds] == nil || params[:card_id] == nil
			render :json => false and return
		end
		room_id = params[:room_id]
		times = params[:times]
		seconds = params[:seconds]
		card_id = params[:card_id]

		if !check_bingo(card_id) || BingoUser.exists?(room_id: room_id, user_id: current_user.id)
			render :json => true and return
		end

		BingoUser.create(room_id: room_id, user_id: current_user.id, times: times, seconds: seconds)
		render :json => true and return
	end
	private

	def check_bingo(card_id)
		card = BingoCard.find_by(id:card_id)
		if card == nil
			return false
		end
		checks = card.checks.split(",")

		# Alignment bingocard sequence
		# 0  1  2  3  4
		# 5  6  7  8  9
		# 10 11 12 13 14
		# 15 16 17 18 19
		# 20 21 22 23 24

		#check horizontal line
		for i in 0..4
			if checks[i*5+0] && checks[i*5+1] && checks[i*5+2] && checks[i*5+3] && checks[i*5+4]
				return true
			end
		end
		#check vertical line
		for i in 0..4
			if checks[i+0] && checks[i+5] && checks[i+10] && checks[i+15] && checks[i+20]
				return true
			end
		end
		#check diagonal line
		if checks[0] && checks[6] && checks[12] && checks[18] && checks[24]
			return true
		end
		if checks[4] && checks[8] && checks[12] && checks[16] && checks[20]
			return true
		end
		return false
	end
end
