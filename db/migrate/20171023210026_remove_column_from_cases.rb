class RemoveColumnFromCases < ActiveRecord::Migration[5.0]
  def change
    remove_column :cases, :type, :boolean
  end
end
