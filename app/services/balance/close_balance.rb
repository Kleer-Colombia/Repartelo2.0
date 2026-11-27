class CloseBalance
  prepend Service

  attr_accessor :balance, :saldos
  def initialize(balance_id)
    @balance = Balance.find(balance_id)
    #TODO move this for a service.
    @saldos =  SaldosActions.new
  end

  def call
    blocking = blocking_invoices
    distribution = @balance.distribution_check
    if blocking.empty? && distribution[:ok]
      distributions = @balance.distributions
      distributions.each do |distribution|
        @saldos.add_saldo(distribution: distribution, balance: balance)
      end
      @balance.close_clearings
      balance.editable = false
      balance.save!

      #Needs refactor
      amount = @balance.resume[:clearing_refund] * -1
      if amount < 0
        concept = "Reintegro de Retenciones - Balance #{@balance.id} - Cliente #{@balance.client}"
        tax = ManualTax.new(tax_master_id: 3, payment_date: Date.current, date: Date.current, amount: amount, concept: concept)
        tax.save!
      end

    else
      messages = []
      if Array(blocking[:unpaid]).any?
        messages << "Las facturas tienen que estar pagadas: marcalas en Pagos (#{blocking[:unpaid].join(', ')})."
      end
      if Array(blocking[:annulled]).any?
        messages << "Estas facturas fueron anuladas con nota crédito; sacalas del balance: #{blocking[:annulled].join(', ')}."
      end
      unless distribution[:ok]
        messages << distribution_message(distribution)
      end
      errors.add(:messages, "No se puede enviar a saldos todavía. #{messages.join(' ')}")
      errors.add(:error_code, :not_acceptable)
    end
  end

  private

  # La utilidad tiene que coincidir con la tabla de distribución, si no la
  # diferencia queda sin repartir (o se reparte de más).
  def distribution_message(check)
    return 'Falta distribuir la utilidad: tocá "Distribuir".' unless check[:distributed_at_all]

    "La distribución quedó desactualizada: hay #{money(check[:expected])} para repartir (utilidad + clearings) " \
      "y la tabla de distribución suma #{money(check[:distributed])}. Volvé a tocar \"Distribuir\"."
  end

  def money(value)
    ActiveSupport::NumberHelper.number_to_currency(value, unit: '$', delimiter: '.', separator: ',', precision: 2)
  end

  # Facturas que impiden cerrar el balance (antes se consultaba si estaban
  # cerradas en Alegra):
  # - sin pago registrado en Pagos (que es de donde salen las retenciones);
  # - anuladas con nota crédito (no se pueden pagar: hay que sacarlas).
  # Las facturas de la época de Alegra que no están en el Drive (sin número
  # o sin XML, ej. anteriores a la facturación electrónica) no bloquean:
  # nadie las puede marcar como pagadas, y solo se pudieron agregar cuando
  # Alegra era la fuente.
  def blocking_invoices
    result = { unpaid: [], annulled: [] }
    @balance.incomes.map(&:invoice).compact.each do |invoice|
      sales_invoice = invoice.sales_invoice
      next unless sales_invoice

      if sales_invoice.annulled?
        result[:annulled] << sales_invoice.number
      elsif !sales_invoice.paid?
        result[:unpaid] << sales_invoice.number
      end
    end
    result.transform_values(&:uniq).reject { |_, numbers| numbers.empty? }
  end
end
