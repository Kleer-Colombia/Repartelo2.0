class TaxDevolution
  prepend Service

  attr_accessor :kleerers,:tax_to_return


  PERCENTAGE_TO_RETURN = 40
  YEAR_TO_RETURN = 2019

  def initialize()
    @kleerers = Kleerer.all
    @tax_to_return = TaxMaster.find_by(name: "Retefuente")
  end

  def call
    header = "balance id, amount to return,"
    @kleerers.each do |kleerer|
      header += "#{kleerer.id},"
    end
    puts header
    Tax.all.select{ |tax| tax.name == @tax_to_return.name and
        !tax.balance.editable and
        tax.amount != 0
    }.map do |tax|
      amount_to_return = calculate_percentage(tax.amount, PERCENTAGE_TO_RETURN)
      kleerCoPart = find_kleerCo_part(tax)
      distributions = tax.balance.distribute(amount_to_return, kleerCoPart)
      prepare_line(amount_to_return,tax.balance, distributions)
      save_data(distributions, tax.balance)
    end
  return true

  rescue StandardError => error
    puts error.to_s
    puts error.backtrace
    errors.add(:messages, "error taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def save_data(distributions, balance)
    distributions.each do |kleerer_id, value|
      ActiveRecord::Base.transaction do
        Saldo.create!(balance: balance, kleerer_id: kleerer_id,
                      amount:value, reference:"/balance/#{balance.id}",
                      concept: "Devolución de renta del balance: #{balance.id}",
                      created_at: balance.date, updated_at: balance.date
        )

        ManualTax.create!(concept: "Devolución de renta del balance: #{balance.id}, para #{Kleerer.find(kleerer_id).name}",
                          date: balance.date,
                          payment_date: balance.date,
                          amount:(value*-1), tax_master_id:@tax_to_return.id)
      end
    end

  end

  def find_kleerCo_part(tax)
    kleerCoPercentage = tax.balance.find_tax_percentage(:kleerCo)
    calculate_percentage(kleerCoPercentage, kleerCoPercentage)
  end

  def  calculate_percentage(amount, percentage)
    return (percentage * amount)/ 100
  end

  def prepare_line(amount_to_return,balance,distributions)
    line = "#{balance.id},#{amount_to_return.to_f.round(2)},"
    @kleerers.each do |kleerer|
      line += "#{distributions[kleerer.id].to_f.round(2)},"
    end
    puts line
  end

end