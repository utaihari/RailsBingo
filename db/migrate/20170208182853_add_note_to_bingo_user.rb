class AddNoteToBingoUser < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_users, :note, :text, default: ""
  end
end
