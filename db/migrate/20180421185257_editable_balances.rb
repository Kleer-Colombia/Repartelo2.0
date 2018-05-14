class EditableBalances < ActiveRecord::Migration[5.1]
  def change
    add_column :balances, :editable, :boolean, default: true
  end
end
