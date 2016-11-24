class AddUseInPlaingToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :AllowUseDuringGame, :boolean
  end
end
