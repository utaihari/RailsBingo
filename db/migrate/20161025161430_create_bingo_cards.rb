class CreateBingoCards < ActiveRecord::Migration[5.0]
  def change
    create_table :bingo_cards do |t|
      t.integer  :room_id
      t.integer  :user_id
      t.string :numbers

      t.timestamps
    end
  end
end
