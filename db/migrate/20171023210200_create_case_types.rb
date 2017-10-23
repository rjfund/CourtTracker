class CreateCaseTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :case_types do |t|
      t.string :title
    end
  end
end
