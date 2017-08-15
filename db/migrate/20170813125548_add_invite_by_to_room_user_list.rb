class AddInviteByToRoomUserList < ActiveRecord::Migration[5.0]
  def change
    add_column :room_user_lists, :invite_by, :integer, default: nil
  end
end
