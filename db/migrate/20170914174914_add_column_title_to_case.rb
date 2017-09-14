class AddColumnTitleToCase < ActiveRecord::Migration[5.0]
  def change
    add_column :cases, :title, :string
  end
end
