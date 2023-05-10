class AddIdToKleerersObjective < ActiveRecord::Migration[5.2]
  def change
    add_column :kleerers_objectives, :id, :primary_key
  end
end
