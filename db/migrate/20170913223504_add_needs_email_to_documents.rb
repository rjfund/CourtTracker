class AddNeedsEmailToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :needs_email, :boolean
  end
end
