class RemoveUserIdToRoomNotices < ActiveRecord::Migration[5.0]
  def change
    remove_column :room_notices, :user_id, :integer
    add_column :room_notices, :user_name, :text
  end
end
