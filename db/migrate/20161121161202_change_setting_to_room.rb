class ChangeSettingToRoom < ActiveRecord::Migration[5.0]
  def change
  	change_column :rooms, :bingo_score, :double, default: 0.0
  	change_column :rooms, :bingo_score, :double, default: 0.5
  	change_column :rooms, :bingo_score, :double, default: 0.2
  end
end
