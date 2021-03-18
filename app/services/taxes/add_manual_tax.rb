class AddManualTax
  prepend Service

  attr_accessor :taxInfo
  def initialize(taxInfo)
    @taxInfo = taxInfo
  end

  def call

    tax = ManualTax.new(amount: @taxInfo[:amount],
                        tax_master_id: @taxInfo[:taxId],
                        concept: @taxInfo[:concept],
                        date: @taxInfo[:date],
                        payment_date: @taxInfo[:paymentDate])
    tax.save!


  rescue StandardError => error
    errors.add(:messages, "error saving manual tax: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end