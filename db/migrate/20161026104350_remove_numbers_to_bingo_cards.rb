class RemoveNumbersToBingoCards < ActiveRecord::Migration[5.0]
  def change
    remove_column :bingo_cards, :numbers, :string
  end
end
