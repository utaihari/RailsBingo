class ChangeColumnToRooms < ActiveRecord::Migration[5.0]
	def up
		change_column :Rooms, :isPlaing, :boolean, null: false, default: false
		change_column :Rooms, :isFinished, :boolean ,null: false, default: false
	end
	def down
		change_column :Rooms, :isPlaing, :boolean, null: true
		change_column :Rooms, :isFinished, :boolean ,null: true
	end
end
