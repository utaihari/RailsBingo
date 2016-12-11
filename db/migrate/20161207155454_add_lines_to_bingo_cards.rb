class AddLinesToBingoCards < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_cards, :bingo_lines, :integer, default: 0
    add_column :bingo_cards, :riichi_lines, :integer, default: 0
    add_column :bingo_cards, :holes, :integer, default: 0
  end
end
