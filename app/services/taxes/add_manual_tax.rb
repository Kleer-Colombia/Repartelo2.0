class AddManualTax
  prepend Service

  attr_accessor :taxInfo
  def initialize(taxInfo)
    @taxInfo = taxInfo
  end

  def call

    if(@taxInfo[:date].include?(@taxInfo[:taxYear]))
      tax = ManualTax.new(amount: @taxInfo[:amount],
                          tax_master_id: @taxInfo[:taxId],
                          concept: @taxInfo[:concept],
                          date: @taxInfo[:date],
                          payment_date: @taxInfo[:paymentDate])
      tax.save!
    else
      raise StandardError, 'La fecha del impuesto no coincide con el tab del año seleccionado, por favor verificalo'
    end

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error saving manual tax: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end