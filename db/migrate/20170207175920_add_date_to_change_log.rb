class AddDateToChangeLog < ActiveRecord::Migration[5.0]
  def change
    add_column :change_logs, :change_date, :date
  end
end
