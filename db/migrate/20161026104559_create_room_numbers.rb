class CreateRoomNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :room_numbers do |t|
      t.integer :room_id
      t.integer :number

      t.timestamps
    end
  end
end
