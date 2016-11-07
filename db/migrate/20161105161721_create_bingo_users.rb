class CreateBingoUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :bingo_users do |t|
      t.integer :room_id
      t.integer :user_id
      t.integer :times
      t.integer :seconds

      t.timestamps
    end
  end
end
