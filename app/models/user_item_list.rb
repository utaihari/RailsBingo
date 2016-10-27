class UserItemList < ApplicationRecord
	belongs_to :user
	belongs_to :community
	belongs_to :item
end
