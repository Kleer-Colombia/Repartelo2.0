class CreateFeatureFlags < ActiveRecord::Migration[5.2]
  def change
    create_table :feature_flags do |t|
      t.string :feature
      t.boolean :status
      t.timestamps
    end

    FeatureFlag.create!(name: "balance>incomes", status: true)
    FeatureFlag.create!(name: "balance>invoices", status: false)


  end
end
