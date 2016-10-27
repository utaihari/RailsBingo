class CreateUserItemLists < ActiveRecord::Migration[5.0]
  def change
    create_table :user_item_lists do |t|
      t.integer  :user_id
      t.integer  :community_id
      t.integer  :item_id

      t.timestamps
    end
  end
end
