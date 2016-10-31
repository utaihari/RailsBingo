class ChangeColumnToBingoCards < ActiveRecord::Migration[5.0]
  def change
  	change_column :bingo_cards, :numbers,:string, default: ""
  end
end
