class Room < ApplicationRecord
	belongs_to :community
	belongs_to :user
	has_many :room_user_list, dependent: :destroy
	has_many :room_number, dependent: :destroy
	has_many :bingo_user, dependent: :destroy
	has_many :bingo_card, dependent: :destroy
end
