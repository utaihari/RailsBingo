class AddBoolToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :AllowUseInGaming, :boolean
  end
end
