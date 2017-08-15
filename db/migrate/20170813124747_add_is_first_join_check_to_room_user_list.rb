class AddIsFirstJoinCheckToRoomUserList < ActiveRecord::Migration[5.0]
  def change
    add_column :room_user_lists, :is_first_join, :boolean, default: true
  end
end
