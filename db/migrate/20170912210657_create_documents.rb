class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.date :date
      t.string :title
      t.string :filed_by

      t.timestamps
    end
  end
end
