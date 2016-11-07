class RenameColumnToRooms < ActiveRecord::Migration[5.0]
  def change
  	rename_column :rooms, :isPlaing, :isPlaying
  end
end
