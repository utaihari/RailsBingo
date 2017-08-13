class AddColumnJoinCountToCommunityUserList < ActiveRecord::Migration[5.0]
  def change
    add_column :community_user_lists, :join_count, :integer, default: 0
  end
end
