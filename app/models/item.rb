class Item < ApplicationRecord
	has_many :user_item_list, dependent: :destroy
end
