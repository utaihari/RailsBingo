class AddDoneBingoToBingoCard < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_cards, :done_bingo, :boolean, default: false
  end
end
