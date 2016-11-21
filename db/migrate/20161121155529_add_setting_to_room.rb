class AddSettingToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :bingo_score, :double
    add_column :rooms, :riichi_score, :double
    add_column :rooms, :hole_score, :double
  end
end
