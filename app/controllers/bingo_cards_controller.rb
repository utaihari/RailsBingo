# coding: utf-8

class BingoCardsController < ApplicationController
	def show
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
		RoomUserList.create(room_id:params[:room_id],user_id: current_user.id)
		redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@bingo_card.id)
	end

	def result
		bingo_users = BingoUser.where(params[:room_id]).order("BingoUser.times ASC, BingoUser.seconds ASC")
		@ranking = 0
		bingo_users.each_with_index do |user, i|
			if user.id == current_user.index
				@ranking = i+1
			end
		end
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
		card = BingoCard.find_by(user_id:current_user.id,room_id:params[:room_id])
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
		if params[:room_id] == nil || times = params[:times] == nil || seconds = params[:seconds] == nil || card_id = params[:card_id] == nil
			render :json => false and return
		end
		room_id = params[:room_id]
		times = params[:times]
		seconds = params[:seconds]
		card_id = params[:card_id]

		if check_bingo(card_id) || BingoUser.exists?(room_id: room_id, user_id: current_user.id)
			render :json => false and return
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
