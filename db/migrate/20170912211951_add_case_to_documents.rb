class AddCaseToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_reference :documents, :case, foreign_key: true
  end
end
