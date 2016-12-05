class AddRoomIdToUserItemLists < ActiveRecord::Migration[5.0]
  def change
    add_column :user_item_lists, :room_id, :integer, default: 0
  end
end
