class RemoveUseInPlaingToItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :AllowUseInGaming, :boolean
  end
end
