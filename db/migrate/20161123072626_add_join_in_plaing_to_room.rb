class AddJoinInPlaingToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :AllowJoinDuringGame, :boolean, default: true
  end
end
