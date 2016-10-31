class AddColumnCheckesToBingoCards < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_cards, :checks, :string
  end
end
