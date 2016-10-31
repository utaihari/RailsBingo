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
	end

	def create
		@bingo_card = BingoCard.find_by(room_id: params[:room_id], user_id: current_user.id)
		if @bingo_card != nil
			redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],@bingo_card.id) and return
		end

		numbers = make_bingo_num()
		checks =[]
		25.times { |n|
			checks << "f"
		}

		@bingo_card = BingoCard.create!(room_id:params[:room_id],user_id:current_user.id,numbers: numbers.join(","),checks: checks.join(","))
		redirect_to community_room_bingo_card_path(params[:community_id],params[:room_id],bingo_card.id)
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

end
