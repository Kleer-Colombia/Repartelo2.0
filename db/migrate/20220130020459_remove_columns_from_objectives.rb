class RemoveColumnsFromObjectives < ActiveRecord::Migration[5.2]
  def change
    remove_column :objectives, :kleerer_id
  end
end
