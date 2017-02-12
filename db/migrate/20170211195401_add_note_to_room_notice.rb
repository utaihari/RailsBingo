class AddNoteToRoomNotice < ActiveRecord::Migration[5.0]
  def change
    add_column :room_notices, :note, :text, default: ""
  end
end
