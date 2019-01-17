class CreateFeatureFlags < ActiveRecord::Migration[5.2]
  def change
    create_table :feature_flags do |t|
      t.string :feature
      t.boolean :status
      t.timestamps
    end

    FeatureFlag.create!(feature: "balance-incomes", status: false)
    FeatureFlag.create!(feature: "balance-invoices", status: true)


  end
end
