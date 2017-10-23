class AddLocationToHearings < ActiveRecord::Migration[5.0]
  def change
    add_column :hearings, :location, :string
  end
end
