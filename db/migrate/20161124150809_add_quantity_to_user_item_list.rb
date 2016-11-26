class AddQuantityToUserItemList < ActiveRecord::Migration[5.0]
  def change
    add_column :user_item_lists, :quantity, :integer , default: 0
  end
end
