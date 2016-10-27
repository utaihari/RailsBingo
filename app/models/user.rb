class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  has_many :community, dependent: :destroy
  has_many :community_user_list, dependent: :destroy
  has_many :room_user_list, dependent: :destroy
  has_many :bingo_card, dependent: :destroy
  has_many :user_item_list, dependent: :destroy

end
