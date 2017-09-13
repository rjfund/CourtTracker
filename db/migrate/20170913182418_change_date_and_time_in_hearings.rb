class ChangeDateAndTimeInHearings < ActiveRecord::Migration[5.0]
  def change
    remove_column :hearings, :time, :time
    remove_column :hearings, :date
  end
end
