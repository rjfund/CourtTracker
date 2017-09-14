class AddUserReferenceToCases < ActiveRecord::Migration[5.0]
  def change
    add_reference :cases, :user, foreign_key: true
  end
end
