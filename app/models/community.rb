class Community < ApplicationRecord
	belongs_to :user
	has_many :community_user_list, dependent: :destroy
	has_many :room, dependent: :destroy
	has_many :user_item_list, dependent: :destroy
	has_many :community_administrator, dependent: :destroy

	def self.search(search)
    	if search
    		Community.where(['name LIKE ?', "%#{search}%"])
    	else
      		Community.all
      	end
	end
end
