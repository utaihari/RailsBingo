class AddColorToRoomNotices < ActiveRecord::Migration[5.0]
  def change
    add_column :room_notices, :color, :text, default: "black"
  end
end
