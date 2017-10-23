class AddCaseTypeRefAgainToCases < ActiveRecord::Migration[5.0]
  def change
    add_reference :cases, :case_type, foreign_key: true
  end
end
