class AddCaseTypeRefToCases < ActiveRecord::Migration[5.0]
  def change
    add_reference :cases, :type
  end
end
