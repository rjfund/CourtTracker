class AddColumnNeedsEmailToHearings < ActiveRecord::Migration[5.0]
  def change
    add_column :hearings, :needs_email, :boolean, default: false
  end
end
