class CreateRepresentativeMarketRates < ActiveRecord::Migration[5.2]
  def change
    create_table :representative_market_rates do |t|
      t.decimal :rate
      t.date :date
      t.string :currency

      t.timestamps
    end
  end
end
