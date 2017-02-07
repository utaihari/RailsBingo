class ChangeLogTypeToChangeLog < ActiveRecord::Migration[5.0]
  def change
  	change_column :change_logs, :log_type, :integer, default: 0
  end
end
