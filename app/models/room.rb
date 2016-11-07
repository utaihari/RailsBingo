class Room < ApplicationRecord
	belongs_to :community
	has_many :room_user_list, dependent: :destroy
	has_many :room_number, dependent: :destroy
	has_many :bingo_user, dependent: :destroy
end
