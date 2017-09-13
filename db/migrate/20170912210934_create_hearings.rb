class CreateHearings < ActiveRecord::Migration[5.0]
  def change
    create_table :hearings do |t|
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
