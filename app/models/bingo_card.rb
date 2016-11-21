class BingoCard < ApplicationRecord
	belongs_to :user
	belongs_to :room
end
