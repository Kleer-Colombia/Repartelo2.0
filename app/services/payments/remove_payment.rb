# Desmarca una factura como pagada (vuelve a Pendientes) y saca sus
# retenciones de los balances abiertos que la usan.
class RemovePayment
  prepend Service

  attr_reader :number

  def initialize(params)
    @number = params[:number].to_s
  end

  def call
    invoice = SalesInvoice.find_by(number: @number)
    return fail_with("la factura #{@number} no existe", :not_found) unless invoice&.payment
    if invoice.used_in_closed_balance?
      return fail_with("la factura #{@number} ya se usó en un balance cerrado: su pago no se puede borrar")
    end

    updated = nil
    ActiveRecord::Base.transaction do
      invoice.payment.destroy!
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
end
