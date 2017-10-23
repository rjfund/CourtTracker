class AddTypeToCases < ActiveRecord::Migration[5.0]
  def change
    add_column :cases, :type, :boolean, :default => false
  end
end
