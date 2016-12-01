class AddEffectToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :effect, :float , default: 0
    add_column :items, :is_select_number, :boolean, default: false
  end
end
