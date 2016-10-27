class CreateCommunityUserLists < ActiveRecord::Migration[5.0]
  def change
    create_table :community_user_lists do |t|
      t.integer  :community_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
