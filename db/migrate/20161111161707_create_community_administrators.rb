class CreateCommunityAdministrators < ActiveRecord::Migration[5.0]
  def change
    create_table :community_administrators do |t|
      t.integer :community_id
      t.integer :user_id

      t.timestamps
    end
  end
end
