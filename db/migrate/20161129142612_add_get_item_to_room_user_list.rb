class AddGetItemToRoomUserList < ActiveRecord::Migration[5.0]
  def change
    add_column :room_user_lists, :got_item_pre_game, :boolean, :default => false
    add_column :room_user_lists, :got_item_after_game, :boolean, :default => false
  end
end
