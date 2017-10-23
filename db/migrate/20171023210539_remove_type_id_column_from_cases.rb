class RemoveTypeIdColumnFromCases < ActiveRecord::Migration[5.0]
  def change
    remove_column :cases, :type_id, :integer
  end
end
