class Community < ApplicationRecord
	belongs_to :user
	has_many :community_user_lists, dependent: :destroy
	has_many :rooms, dependent: :destroy
	has_many :user_item_lists, dependent: :destroy
	has_many :community_administrators, dependent: :destroy

	def self.search(search)
    	if search
    		Community.where(['name LIKE ?', "%#{search}%"])
    	else
      		Community.all
      	end
	end
end
