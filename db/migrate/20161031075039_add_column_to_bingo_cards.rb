class AddColumnToBingoCards < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_cards, :numbers, :string
  end
end
