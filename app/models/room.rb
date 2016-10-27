class Room < ApplicationRecord
	belongs_to :user
	belongs_to :community
	has_many :room_user_list, dependent: :destroy
	has_many :room_number, dependent: :destroy
end
