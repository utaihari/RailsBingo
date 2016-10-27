class BingoCard < ApplicationRecord
	belongs_to :user
	belongs_to :room
	has_many :card_number, dependent: :destroy
end
