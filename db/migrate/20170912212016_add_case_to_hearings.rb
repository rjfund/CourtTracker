class AddCaseToHearings < ActiveRecord::Migration[5.0]
  def change
    add_reference :hearings, :case, foreign_key: true
  end
end
