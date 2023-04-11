class AddExtKleererToClearings < ActiveRecord::Migration[5.2]
  def change
    add_column :clearings, :ext_kleerer, :string
  end
end
