class AddTimeToHearing < ActiveRecord::Migration[5.0]
  def change
    add_column :hearings, :time, :datetime
  end
end
