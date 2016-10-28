# coding: utf-8
class BingoCardsController < ApplicationController
	def show
		numbers = BingoCard.joins(:card_number).where(user_id: current_user.id, room_id: params[:room_id]).select("number")
		@numbers = []
		numbers.each{|n|
			@numbers << n[:number]
		}
	end

	def create

		if BingoCard.exists?(room_id: params[:room_id], user_id: current_user.id)
			numbers = BingoCard.joins(:card_number).where(user_id: current_user.id, room_id: params[:room_id]).select("number")
			@numbers = []
			numbers.each{|n|
				@numbers << n.number
			}
			render 'show' and return
		end

		@card = BingoCard.create(room_id: params[:room_id], user_id: current_user.id)

		@numbers = make_bingo_num()
		card_id = @card.id

		@numbers.each{|number|
			CardNumber.create!(bingo_card_id: card_id, number: number)
		}
		render 'show'
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
