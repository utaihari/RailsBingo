class AddInviteBonusToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :invite_bonus, :integer, default: 0
  end
end
