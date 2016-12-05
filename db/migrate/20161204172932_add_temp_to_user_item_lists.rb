class AddTempToUserItemLists < ActiveRecord::Migration[5.0]
  def change
    add_column :user_item_lists, :temp, :boolean, default: false
  end
end
