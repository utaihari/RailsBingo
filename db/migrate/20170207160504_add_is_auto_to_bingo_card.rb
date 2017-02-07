class AddIsAutoToBingoCard < ActiveRecord::Migration[5.0]
  def change
    add_column :bingo_cards, :is_auto, :boolean, default: false
  end
end
