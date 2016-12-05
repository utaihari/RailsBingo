class AddCanBringItemToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :can_bring_item, :boolean, default: false
    add_column :rooms, :number_of_free, :integer, default: 1
  end
end
