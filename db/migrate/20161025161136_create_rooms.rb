class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer  :community_id
      t.boolean :isPlaing
      t.boolean :isFinished

      t.timestamps
    end
  end
end
