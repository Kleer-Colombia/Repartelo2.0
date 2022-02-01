class CreateJoinTableKleerersObjectives < ActiveRecord::Migration[5.2]
  def change
    create_join_table :kleerers, :objectives do |t|
      t.references :kleerer, foreign_key: true
      t.references :objective, foreign_key: true
    end
  end
end
