class ChangeColumnTypeInInviteCode < ActiveRecord::Migration[5.0]
  def change
    change_column :invite_codes, :code, :bigint
  end
end
