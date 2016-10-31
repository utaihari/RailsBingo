class AddColumnToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :rates, :string
  end
end
