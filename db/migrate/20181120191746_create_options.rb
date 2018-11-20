class CreateOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :options do |t|
      t.string :name
      t.decimal :value

      t.timestamps
    end

    Option.create!(name: "socio", value: 5)
    Option.create!(name: "full", value: 15)
    Option.create!(name: "parcial", value: 25)
    Option.create!(name: "otro", value: 10)
    Option.create!(name: "home", value: 0)
  end
end
