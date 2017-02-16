class CreateUserNotices < ActiveRecord::Migration[5.0]
  def change
    create_table :user_notices do |t|
      t.integer :user_id
      t.integer :room_id
      t.text :notice, default: ""

      t.timestamps
    end
  end
end
