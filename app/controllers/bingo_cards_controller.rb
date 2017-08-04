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

		@members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto").order("bingo_cards.is_auto ASC, users.id ASC")
		@cards = BingoCard.where(room_id: @room.id).order("user_id ASC")
		room_id = 0
		if !@room.can_bring_item
			room_id = @room.id
		end
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type, items.description").order("items.name")
		@is_auto = @card.is_auto
		@done_bingo = @card.done_bingo
		@get_items = distribute_item(params[:community_id], params[:room_id])
		@invite_url = "http://www.bingo-live.tk"+pre_join_room_path(@community.id,@room.id)+"?invite_by=#{current_user.id}"
	end

	def create
		@community = Community.find(params[:community_id])
		@room = Room.find(params[:room_id])
		@card = BingoCard.find_by(room_id: params[:room_id], user_id: current_user.id)
		if @card != nil
			redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@card.id) and return
		end

		notice = "参加しました"
		if session[:invite_by] != nil
			user = User.find(session[:invite_by])
			notice = "#{user.name}さんに招待されました"
		end

		RoomNotice.create!(room_id: params[:room_id], user_name: current_user.name, notice: notice, color: "#333399")
		settings = UserSetting.find_by(user_id: current_user.id)
		if settings == nil
			settings = UserSetting.create(user_id: current_user.id)
		end

		@members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: @room.id}, :room_user_lists => {room_id: @room.id}).select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto").order("bingo_cards.is_auto ASC, users.id ASC")
		@cards = BingoCard.where(room_id: @room.id).order("user_id ASC")

		@numbers = make_bingo_num(@room.number_of_free.to_i)
		@checks =[]
		25.times { |n|
			@checks << "f"
		}
		@card = BingoCard.create!(room_id:params[:room_id], user_id:current_user.id, numbers: @numbers.join(","), checks: @checks.join(","), is_auto: settings.is_auto)
		@get_items = distribute_item(params[:community_id], params[:room_id])
		@is_auto = @card.is_auto
		@done_bingo = @card.done_bingo
		room_id = 0
		if !@room.can_bring_item
			room_id = @room.id
		end
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type, items.description").order("items.name")
		@invite_url = "http://www.bingo-live.tk"+pre_join_room_path(@community.id,@room.id)+"?invite_by=#{current_user.id}"
		#invite bonus
		if session[:invite_by] != nil
			user_notice = "あなたが招待した#{current_user.name}さんがゲームに参加しました"
			UserNotice.create(user_id: session[:invite_by], room_id: @room.id, notice: user_notice)
			items = item_deliver(session[:invite_by], @room.id, @room.invite_bonus)
			item_names = []
			items.each { |i|
			item_names.push(i.name) }
			user_notice = "アイテム #{item_names.join(",")}　を獲得しました"
			UserNotice.create(user_id: session[:invite_by], room_id: @room.id, notice: user_notice)
		end
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

	def member_list
		@room = Room.joins(:community).joins(:user).find(params[:room_id])
		@members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto").order("bingo_cards.is_auto ASC, users.id ASC")
		@cards = BingoCard.where(room_id:@room.id).order("user_id ASC")
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

		user_item = UserItemList.where(user_id: current_user.id, community_id: community_id, temp: !room.can_bring_item, room_id: room_id).includes(:user).includes(:community).includes(:item)

		selected_items.each do |item|
			i = user_item.find_by(item_id: item.id)
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
		@items = UserItemList.joins(:item).where(user_id: current_user.id, community_id: params[:community_id], temp: !@room.can_bring_item, room_id: room_id).select("user_item_lists.id AS id, items.name, items.AllowUseDuringGame, items.id AS item_id, quantity, items.item_type, items.description")
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

		quantity = (params[:bingos].to_f * room.bingo_score.to_f) + (params[:riichis].to_f * room.riichi_score.to_f) + (params[:holes].to_f * room.hole_score.to_f)

		selected_items = item_select(quantity)

		selected_items.each do |item|
			i = UserItemList.joins(:user).joins(:community).joins(:item).find_by(user_id: current_user.id, community_id: params[:community_id], item_id: item.id, temp: false)
			if i != nil
				i.quantity += 1
				i.save
			else
				UserItemList.create(user_id: current_user.id, community_id: params[:community_id], item_id: item.id, quantity: 1, temp: falseee)
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
						i = rand(numbers.length)
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

		room_numbers = RoomNumber.find_by(room_id:card.room_id)
		if !room_numbers.include?(card.numbers.split(",")[index])
			return
		end

		checks = card.checks.split(",")

		if checks[index] ==  "t"
			return
		end

		checks[index] = "t"

		if card.riichi_lines < params[:riichi_lines].to_i && params[:is_auto] == false
			RoomNotice.create(room_id: params[:room_id], user_name: current_user.name, notice: "リーチ！", color: "magenta")
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

	def uncheck_number
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

		checks[index] = "f"

		card.checks = checks.join(",")
		card.riichi_lines = params[:riichi_lines].to_i
		card.holes -= 1
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
		item = Item.new

		if params[:from_room_master].to_s == "true"
			if room.user_id != current_user.id
				render :json => "error3" and return
			end
			item = Item.find(params[:item_id])
		else
			user_item = UserItemList.joins(:user).joins(:community).joins(:item).find(params[:item_id])
			item = Item.find(user_item.item_id)
			if room.isPlaying && !item.AllowUseDuringGame
				render :json => "error1" and return
			end

			if user_item == nil
				render :json => "error2" and return
			end

			if user_item.user_id != current_user.id
				render :json => "error3" and return
			end

			if item.item_type.to_i == 3
				if !room.isPlaying
					render :json => "このアイテムはゲーム中のみ使用できます" and return
				end
			end

			quantity = user_item.quantity
			if quantity == 1
				user_item.destroy
			else
				user_item.quantity -= 1
				user_item.save
			end
		end

		# notice = "#{item.name}を使用しました"
		# RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
		selected_num = -1

		case item.item_type.to_i
		when 0
			selected_num = increase_rate_random_num(params[:card_id], item.effect)
			notice = "#{selected_num} の確率が上昇しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json => notice.to_json and return
		when 1
			if params[:number] == nil
				render :json => "error3" and return
			end
			increase_rate(room.id, item.effect, params[:number])
			notice = "#{params[:number]} の確率が上昇しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json => notice.to_json and return
		when 2
			add_free(params[:card_id])
			notice = "#{item.name}を使用しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json => "FREEが追加されました".to_json and return
		when 3
			n = Array.new
			n = delete_number(room.id, item.effect.to_i)
			notice = "#{n.join(',')}が取り消されました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json =>	notice.to_json and return
		when 4
			shuffle_card(params[:card_id])
			notice = "#{item.name}を使用しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json => "カード上の数字がシャッフルされました".to_json and return
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

		if user_item.user_id != current_user.id
			render :json => "error3" and return
		end

		quantity = user_item.quantity

		case item.item_type.to_i
		when 0
			selected_num = increase_rate_random_num_all(params[:card_id], item.effect, quantity)
			user_item.destroy
			notice = "#{selected_num.join(", ")} の確率が上昇しました"
			RoomNotice.create(room_id: room.id, user_name: current_user.name, notice: notice)
			render :json => notice.to_json and return
		when 1
			render :json => "このアイテムはまとめて使用できません".to_json and return
		when 2
			use_quantity = add_free_all(params[:card_id], quantity.to_i)

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

	def increase_rate_random_num(card_id, effect)
		card = BingoCard.joins(:user).joins(:room).find(card_id)
		room = Room.find(card.room_id)
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
		increase_rate(room.id, effect, selected_num)
		return selected_num
	end

	def increase_rate_random_num_all(card_id, effect, quantity)
		card = BingoCard.joins(:user).joins(:room).find(card_id)
		room = Room.find(card.room_id)
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
		increase_rates(room.id, effect, selected_num)
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
	def add_free(card_id)
		card = BingoCard.joins(:user).joins(:room).find(card_id)
		room = Room.find(card.room_id)
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

	def add_free_all(card_id, quantity)
		card = BingoCard.joins(:user).joins(:room).find(card_id)
		room = Room.find(card.room_id)
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

		return_val = 0
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
				return (use_quantity + 1)
			end
			return_val = use_quantity + 1
		}
		card.numbers = numbers.join(',')
		card.save
		return return_val
	end

	def delete_number(room_id, quantity)
		room = Room.find(room_id)
		room_numbers = RoomNumber.where(room_id: room_id).order(created_at: :desc)
		room_rates = room.rates.split(",")

		delete_number = Array.new
		quantity.times do |index|
			if room_numbers[index] == -1
				room.rates = room_rates.join(",")
				room.save
				return delete_number
			end
			delete_number << room_numbers[index].number
			room_rates[room_numbers[index].number-1] = room.pre_rate * 2
			room_numbers[index].destroy
		end
		room.rates = room_rates.join(",")
		room.save
		return delete_number
	end

	def shuffle_card(card_id)
		card = BingoCard.joins(:user).joins(:room).find(card_id)
		temp_card = Array.new

		card_numbers = card.numbers.split(",")
		card_checks = card.checks.split(",")

		card_numbers.each_with_index { |number, index|
			temp_card << {number: number, check: card_checks[index]}
		}
		temp_card.shuffle!

		numbers = Array.new
		checks = Array.new
		temp_card.each{|t|
			numbers << t[:number]
			checks << t[:check]
		}
		card.numbers = numbers.join(",")
		card.checks = checks.join(",")
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

	def get_card_numbers
		card = BingoCard.find(params[:card_id])
		card_numbers = card.numbers.split(",")
		render :json => card_numbers
	end

	def done_bingo
		if params[:room_id] == nil || params[:times] == nil || params[:seconds] == nil || params[:card_id] == nil
			render :json => false and return
		end
		room = Room.find(params[:room_id])
		room_id = params[:room_id]
		# times = params[:times]
		seconds = params[:seconds]
		card_id = params[:card_id]

		if !check_bingo(card_id, room_id)
			render :json => false and return
		end

		if BingoUser.exists?(room_id: room_id, user_id: current_user.id)
			render :json => true and return
		end

		notice = "ビンゴ！！！"
		RoomNotice.create!(room_id: params[:room_id], user_name: current_user.name, notice: notice, color: "red")

		card = BingoCard.joins(:user).joins(:room).find(card_id)
		card.bingo_lines += 1
		card.done_bingo = true
		card.save

		BingoUser.create(room_id: room_id, user_id: current_user.id, times: room.times, seconds: seconds)
		render :json => true and return
	end

	def auto_check
		card = BingoCard.find(params[:card_id])
		settings = UserSetting.find_by(user_id:current_user.id)
		is_auto = params[:is_auto_check]
		if settings == nil
			settings = UserSetting.create(user_id: current_user.id, is_auto: is_auto)
		end
		card.is_auto = is_auto
		settings.is_auto = is_auto

		card.save
		settings.save
		render :json => true and return
	end


	private

	def check_bingo(card_id, room_id)
		card = BingoCard.find_by(id:card_id)
		if card == nil
			return false
		end
		room_numbers = RoomNumber.where(room_id: room_id)
		room_numbers_array = []
		room_numbers.each { |n|
			room_numbers_array << n.number.to_i
		}
		checks = card.checks.split(",")
		card_numbers = card.numbers.split(",")

		checks.each_with_index { |check, i|
			if check == 't'
				if !room_numbers_array.include?(card_numbers[i].to_i)
					return false
				end
			end
		}

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

	def item_select(quantity)
		items = Item.all

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
		return selected_items
	end
	def item_deliver(user_id, room_id, quantity)
		selected_items = item_select(quantity.to_i)
		room = Room.find(room_id)
		user_item = UserItemList.where(user_id: user_id, community_id: room.community_id, temp: !room.can_bring_item, room_id: room_id).includes(:user).includes(:community).includes(:item)

		selected_items.each do |item|
			i = user_item.find_by(item_id: item.id)
			if i != nil
				i.quantity += 1
				i.save
			else
				UserItemList.create(user_id: user_id, community_id: room.community_id, item_id: item.id, quantity: 1, temp: !room.can_bring_item, room_id: room_id)
			end
		end
		return selected_items
	end

end
