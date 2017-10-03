class CreateVoiceMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :voice_messages do |t|
      t.text :url
      t.references :user, foreign_key: true
      t.boolean :is_new

      t.timestamps
    end
  end
end
