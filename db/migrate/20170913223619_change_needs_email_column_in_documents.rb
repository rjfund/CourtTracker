class ChangeNeedsEmailColumnInDocuments < ActiveRecord::Migration[5.0]
  def change
    change_column :documents, :needs_email, :boolean, :default => false
  end
end
