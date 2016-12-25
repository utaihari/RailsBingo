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

		room_id = 0
		if !@room.can_bring_item
			room_id = @room.id
		end
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type").order("items.name")

		@get_items = distribute_item(params[:community_id], params[:room_id])
	end

	def create
		@community = Community.find(params[:community_id])
		@room = Room.find(params[:room_id])
		@card = BingoCard.find_by(room_id: params[:room_id], user_id: current_user.id)
		if @card != nil
			redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@card.id) and return
		end

		@numbers = make_bingo_num(@room.number_of_free.to_i)
		@checks =[]
		25.times { |n|
			@checks << "f"
		}
		@card = BingoCard.create!(room_id:params[:room_id], user_id:current_user.id, numbers: @numbers.join(","), checks: @checks.join(","))
		@get_items = distribute_item(params[:community_id], params[:room_id])

		room_id = 0
		if !@room.can_bring_item
			room_id = @room.id
		end
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type").order("items.name")
		render :action => 'show', community_id: params[:community_id], room_id: params[:room_id], id: @card.id
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
		render :partial => "others-card", :locals => {user_name: user_name,  room: @room, card: @card, numbers: @numbers, checks: @checks, isWindow: true }, :layout => false and return
	end

	def distribute_item(community_id, room_id)

		user = RoomUserList.joins(:user).joins(:room).find_by(user_id: current_user.id, room_id: room_id)

		if user.got_item_pre_game
			return []
		end

		room = Room.find(room_id)
		items = Item.all
		quantity = room.profit.to_i


		rarity_sum = 0
		items.each do |item|
			rarity_sum += item.rarity
		end

		random_arr = []
		quantity.times{
			random_arr.push(rand(rarity_sum) + 1)
		}

		selected_items = []
		random_arr.each do |r|
			items.each do |item|
				r -= item.rarity
				if r <= 0
					selected_items.push(item)
					break
				end
			end
		end

		room_id = 0
		if !room.can_bring_item
			room_id = room.id
		end
		selected_items.each do |item|
			i = UserItemList.joins(:user).joins(:community).joins(:item).find_by(user_id: current_user.id, community_id: community_id, item_id: item.id, temp: !room.can_bring_item, room_id: room_id)
			if i != nil
				i.quantity += 1
				i.save
			else
				UserItemList.create(user_id: current_user.id, community_id: community_id, item_id: item.id, quantity: 1, temp: !room.can_bring_item, room_id: room_id)
			end
		end
		user.got_item_pre_game = true
		user.save
		return selected_items
	end

	def items
		@room = Room.find(params[:room_id])
		room_id = 0
		if !@room.can_bring_item
			room_id = @room.id
		end
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type")
		numberlist = BingoCard.find_by(user_id: current_user.id, room_id: params[:room_id])
		@numbers = []
		numbers = numberlist.numbers.split(",")
		numbers.each{|n|
			@numbers << n.to_i
		}
		@checks = numberlist.checks.split(",")
	end

	def get_items

		user = RoomUserList.joins(:user).joins(:room).find_by(user_id: current_user.id, room_id: params[:room_id])

		room = Room.find(params[:room_id])

		if !room.can_bring_item
			return []
		end

		if user.got_item_after_game || !room.isFinished
			return []
		end

		items = Item.all
		quantity = (params[:bingos].to_f * room.bingo_score.to_f) + (params[:riichis].to_f * room.riichi_score.to_f) + (params[:holes].to_f * room.hole_score.to_f)

		rarity_sum = 0
		items.each do |item|
			rarity_sum += item.rarity
		end

		random_arr = []
		quantity.to_i.times{
			random_arr.push(rand(rarity_sum) + 1)
		}

		selected_items = []
		random_arr.each do |r|
			items.each do |item|
				r -= item.rarity
				if r <= 0
					selected_items.push(item)
					break
				end
			end
		end

		selected_items.each do |item|
			i = UserItemList.joins(:user).joins(:community).joins(:item).find_by(user_id: current_user.id, community_id: params[:community_id], item_id: item.id)
			if i != nil
				i.quantity += 1
				i.save
			else
				UserItemList.create(user_id: current_user.id, community_id: params[:community_id], item_id: item.id, quantity: 1)
			end
		end
		user.got_item_after_game = true
		user.save
		@items = selected_items
	end
	def bingo_card
		numberlist = BingoCard.find_by(user_id: current_user.id, room_id: params[:room_id])
		@numbers = []
		numbers = numberlist.numbers.split(",")
		numbers.each{|n|
			@numbers << n.to_i
		}
		@checks = numberlist.checks.split(",")
	end
	def make_bingo_num(free_num)
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

		if free_num > 25
			free_num = 25
		end

		if free_num > 0
			#Add free to center of card.
			random_numbers = []
			random_numbers << 12
			free_num -= 1

			#Add free in random.
			if free_num > 0
				free_num.times{
					while true
						i = rand(numbers.length) + 1
						if !random_numbers.include?(i)
							random_numbers << i
							break
						end
					end
				}
			end
			random_numbers.each do |num|
				numbers[num] = -1
			end
		end
		return numbers
	end

	def check_number
		if params[:card_id] == nil
			return
		end
		card = BingoCard.joins(:user).joins(:room).find_by(id:params[:card_id])
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

		if card.riichi_lines != params[:riichi_lines].to_i
			RoomNotice.create(room_id: params[:room_id], user_name: current_user.name, notice: "リーチ！")
		end
		card.checks = checks.join(",")
		card.riichi_lines = params[:riichi_lines].to_i
		card.holes += 1
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
		room = Room.joins(:community).find(params[:room_id])
		user_item = UserItemList.find(params[:item_id])
		item = Item.find(user_item.item_id)


		if room.isPlaying && !item.AllowUseDuringGame
			render :json => "error1" and return
		end

		if user_item == nil
			render :json => "error2" and return
		end

		notice = "#{item.name}を使用しました"
		RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)

		quantity = user_item.quantity
		if quantity == 1
			user_item.destroy
		else
			user_item.quantity -= 1
			user_item.save
		end

		selected_num = -1

		case item.item_type.to_i
		when 0
			selected_num = increase_rate_random_num(room.id, item.effect)
			render :json => "#{selected_num} の確率が上昇しました".to_json and return
		when 1
			if params[:number] == nil
				render :json => "error3" and return
			end
			increase_rate(room.id, item.effect, params[:number])
			render :json => "#{params[:number]} の確率が上昇しました".to_json and return
		when 2
			add_free(room.id)
			render :json => "FREEが追加されました".to_json and return
		end
	end

	def use_item_all
		room = Room.joins(:community).find(params[:room_id])
		user_item = UserItemList.find(params[:item_id])
		item = Item.find(user_item.item_id)

		if room.isPlaying && !item.AllowUseDuringGame
			render :json => "error1" and return
		end

		if user_item == nil
			render :json => "error2" and return
		end

		quantity = user_item.quantity

		case item.item_type.to_i
		when 0
			notice = "#{item.name}を#{user_item.quantity}個使用しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			selected_num = increase_rate_random_num_all(room.id, item.effect, quantity)
			user_item.destroy
			render :json => "#{selected_num.join(", ")} の確率が上昇しました".to_json and return
		when 1
			render :json => "このアイテムはまとめて使用できません".to_json and return
		when 2
			use_quantity = add_free_all(room.id, quantity)

			notice = "#{item.name}を#{use_quantity}個使用しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)

			if quantity - use_quantity <= 0
				user_item.destroy
			else
				user_item.quantity -= use_quantity
				user_item.save
			end
			render :json => "FREEが追加されました".to_json and return
		end
	end

	def increase_rate_random_num(room_id, effect)
		card = BingoCard.find_by(user_id:current_user.id, room_id:room_id)
		room = Room.find(room_id)
		room_numbers_rate = room.rates.split(',')
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f' && room_numbers_rate[number.to_i + 1].to_i != 0 && number.to_i != -1
				numbers_unchecked.push(number)
			end
		end

		selected_num = numbers_unchecked[rand(numbers_unchecked.length())]
		increase_rate(room_id, effect, selected_num)
		return selected_num
	end

	def increase_rate_random_num_all(room_id, effect, quantity)
		card = BingoCard.find_by(user_id:current_user.id, room_id:room_id)
		room = Room.find(room_id)
		room_numbers_rate = room.rates.split(',')
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f' && room_numbers_rate[number.to_i + 1].to_i != 0 && number.to_i != -1
				numbers_unchecked.push(number)
			end
		end

		selected_num = []
		quantity.times{|i|
			selected_num << numbers_unchecked[rand(numbers_unchecked.length())]
		}
		increase_rates(room_id, effect, selected_num)
		return selected_num
	end

	def increase_rate(room_id, effect, number)
		room = Room.joins(:user).joins(:community).find(room_id)
		rates = room.rates.split(',')

		rate_size = 0
		rates.each do |rate|
			rate_size += rate.to_i
		end

		increase = rate_size.to_f * effect.to_f
		rates[number.to_i-1] = rates[number.to_i-1].to_i + increase

		room.rates = rates.join(',')
		room.save
	end

	def increase_rates(room_id, effect, numbers)
		room = Room.joins(:user).joins(:community).find(room_id)
		rates = room.rates.split(',')
		rate_size = 0
		rates.each do |rate|
			rate_size += rate.to_i
		end
		numbers.each{|number|
			increase = rate_size.to_f * effect.to_f
			rates[number.to_i-1] = rates[number.to_i-1].to_i + increase
			rate_size += increase
		}
		room.rates = rates.join(',')
		room.save
	end
	def add_free(room_id)
		card = BingoCard.joins(:user).joins(:room).find_by(user_id:current_user.id, room_id:room_id)
		room = Room.find(room_id)
		room_numbers_rate = room.rates.split(',')
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f' && room_numbers_rate[number.to_i-1].to_i != 0 && number.to_i != -1
				numbers_unchecked.push(number)
			end
		end
		if numbers_unchecked.blank?
			return
		end
		selected_num = numbers_unchecked[rand(numbers_unchecked.length()+1)]

		numbers.each_with_index do |number,index|
			if number == selected_num
				numbers[index] = -1
			end
		end
		card.numbers = numbers.join(',')
		card.save
	end

	def add_free_all(room_id, quantity)
		card = BingoCard.joins(:user).joins(:room).find_by(user_id:current_user.id, room_id:room_id)
		room = Room.find(room_id)
		room_numbers_rate = room.rates.split(',')
		numbers = card.numbers.split(',')
		checks = card.checks.split(',')
		numbers_unchecked = []

		numbers.each_with_index do |number, index|
			if checks[index] == 'f' && room_numbers_rate[number.to_i-1].to_i != 0 && number.to_i != -1
				numbers_unchecked.push(number)
			end
		end
		if numbers_unchecked.blank?
			return 0
		end
		quantity.times{|use_quantity|

			selected_num = numbers_unchecked[rand(numbers_unchecked.length()+1)]

			numbers.each_with_index do |number,index|
				if number == selected_num
					numbers[index] = -1
				end
			end
			numbers_unchecked.delete(selected_num)
			if numbers_unchecked.blank?
				card.numbers = numbers.join(',')
				card.save
				return use_quantity + 1
			end
		}
		card.numbers = numbers.join(',')
		card.save
		return 0
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

		notice = "ビンゴ！"
		RoomNotice.create!(room_id: params[:room_id], user_name: current_user.name, notice: notice)

		card = BingoCard.find(card_id)
		card.bingo_lines += 1
		card.save

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
