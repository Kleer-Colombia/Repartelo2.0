class CloseBalance
  prepend Service

  attr_accessor :balance, :saldos
  def initialize(balance_id)
    @balance = Balance.find(balance_id)
    #TODO move this for a service.
    @saldos =  SaldosActions.new
  end

  def call
    unpaid = unpaid_invoice_numbers
    if unpaid.empty?
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
      errors.add(:messages, "El balance solo se puede enviar a saldos cuando sus facturas estén pagadas. " \
                            "Marcalas como pagadas en Pagos: #{unpaid.join(', ')}")
      errors.add(:error_code, :not_acceptable)
    end
  end

  private

  # Facturas del balance sin pago registrado en Pagos (que es donde se
  # cargan sus retenciones). Antes se consultaba el estado en Alegra.
  def unpaid_invoice_numbers
    invoices = @balance.incomes.map(&:invoice).compact
    invoices.reject { |invoice| invoice.sales_invoice&.paid? }
            .map { |invoice| invoice.number || "id Alegra #{invoice.alegra_id.to_i} (sin número)" }
            .uniq
  end
end
