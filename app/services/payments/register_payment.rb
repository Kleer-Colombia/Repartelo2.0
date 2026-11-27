# "Fue pagada": registra (o corrige) el pago de una factura con su fecha,
# monto y retenciones (Retefuente, Reteica, Reteiva; cualquiera puede ir en
# cero), y actualiza los balances abiertos que usan la factura.
class RegisterPayment
  prepend Service

  attr_reader :number, :data, :user

  def initialize(params)
    @number = params[:number].to_s
    @data = params[:data] || {}
    @user = params[:user]
  end

  def call
    invoice = SalesInvoice.find_by(number: @number)
    return fail_with("la factura #{@number} no existe", :not_found) unless invoice
    return fail_with("la factura #{@number} está anulada") if invoice.annulled?
    if invoice.paid? && invoice.used_in_closed_balance?
      return fail_with("la factura #{@number} ya se usó en un balance cerrado: su pago no se puede cambiar")
    end

    payment = invoice.payment || invoice.build_payment
    payment.assign_attributes(
      source: 'repartelo',
      paid_on: parse_date(@data['paidOn']),
      amount: decimal(@data['amount']),
      retefuente: decimal(@data['retefuente']) || 0,
      reteica: decimal(@data['reteica']) || 0,
      reteiva: decimal(@data['reteiva']) || 0,
      registered_by: @user&.name
    )
    return fail_with(payment.errors.full_messages.join(', ')) unless payment.valid?

    updated = nil
    ActiveRecord::Base.transaction do
      payment.save!
      updated = ApplyPaymentRetentions.new(invoice.reload).call
    end
    { number: invoice.number, updatedBalances: updated }
  end

  private

  def fail_with(message, code = :not_acceptable)
    errors.add(:messages, message)
    errors.add(:error_code, code)
    nil
  end

  def parse_date(value)
    value.present? ? Date.parse(value.to_s) : nil
  rescue ArgumentError
    nil
  end

  def decimal(value)
    return nil if value.blank?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end
end
