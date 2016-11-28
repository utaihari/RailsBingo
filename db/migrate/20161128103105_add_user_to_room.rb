class AddUserToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :user_id, :integer
  end
end
