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
    if blocking.empty?
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
        messages << "Marcá como pagadas en Pagos: #{blocking[:unpaid].join(', ')}."
      end
      if Array(blocking[:annulled]).any?
        messages << "Estas facturas fueron anuladas con nota crédito; sacalas del balance: #{blocking[:annulled].join(', ')}."
      end
      errors.add(:messages, "El balance solo se puede enviar a saldos cuando sus facturas estén pagadas. #{messages.join(' ')}")
      errors.add(:error_code, :not_acceptable)
    end
  end

  private

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
