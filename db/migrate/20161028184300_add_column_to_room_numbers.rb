class AddColumnToRoomNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column :room_numbers, :rate, :integer, default: 10
  end
end
