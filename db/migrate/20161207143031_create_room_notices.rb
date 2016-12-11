class CreateRoomNotices < ActiveRecord::Migration[5.0]
  def change
    create_table :room_notices do |t|
      t.integer :room_id
      t.integer :user_id
      t.text :notice, default: ""

      t.timestamps
    end
  end
end
