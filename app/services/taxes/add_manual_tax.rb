class AddManualTax
  prepend Service

  attr_accessor :taxInfo
  def initialize(taxInfo)
    @taxInfo = taxInfo
  end

  def call

    tax = ManualTax.new(amount: @taxInfo[:amount],
                        tax_master: TaxMaster.find_by_name(@taxInfo[:taxName]),
                        concept: @taxInfo[:concept],
                        date: @taxInfo[:date])
    tax.save!

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error saving manual tax: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end