class AddColumnToCardNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column :card_numbers, :isChecked, :boolean , default: false
  end
end
