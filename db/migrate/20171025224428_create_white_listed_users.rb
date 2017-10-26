class CreateWhiteListedUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :white_listed_users do |t|
      t.string :email
      t.string :name

      t.timestamps
    end
  end
end
