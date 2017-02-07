class CreateUserSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :user_settings do |t|
      t.integer :check_number_freq, default: 5
      t.integer :check_state_freq, default: 8
      t.boolean :is_auto, default: false

      t.timestamps
    end
  end
end
