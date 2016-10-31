class RemoveColumnToRoomNumbers < ActiveRecord::Migration[5.0]
  def change
    remove_column :room_numbers, :rate, :integer
  end
end
