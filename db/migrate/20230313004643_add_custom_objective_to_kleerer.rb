class AddCustomObjectiveToKleerer < ActiveRecord::Migration[5.2]
  def change
    add_column :kleerers_objectives, :has_custom_objective, :bool, default: false
    add_column :kleerers_objectives, :objective_amount, :integer, null: true
  end
end
