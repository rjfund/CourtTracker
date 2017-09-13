class AddTitleToHearings < ActiveRecord::Migration[5.0]
  def change
    add_column :hearings, :title, :string
  end
end
