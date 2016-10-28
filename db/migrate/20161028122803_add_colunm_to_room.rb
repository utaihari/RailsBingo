class AddColunmToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :canUseItem, :boolean
  end
end
