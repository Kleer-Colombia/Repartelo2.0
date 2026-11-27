# Listado de la sección Pagos.
#   pending: facturas no anuladas sin pago registrado (todas).
#   paid:    facturas pagadas emitidas en `year` (por defecto, el actual).
class FindPayments
  prepend Service

  attr_reader :status, :year, :sync

  def initialize(data)
    @status = data[:status].to_s
    @year = data[:year].presence&.to_i || Date.current.year
    @sync = data.fetch(:sync, true)
  end

  def call
    run = DriveInvoiceSync.run_if_stale if @sync
    invoices = @status == 'paid' ? paid : pending
    used = Invoice.used_percentages
    balances = balances_by_number(invoices.map(&:number))

    { invoices: invoices.map { |invoice| serialize(invoice, used.fetch(invoice.number, 0), balances[invoice.number] || []) },
      lastSync: (run || DriveSyncRun.last_finished)&.as_summary,
      driveConfigured: DriveInvoiceSync.configured? }
  rescue StandardError => e
    Rails.logger.error("[FindPayments] #{e.class}: #{e.message}")
    errors.add(:messages, "error buscando pagos: #{e.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def pending
    SalesInvoice.not_annulled.unpaid.order(:issue_date, :number).to_a
  end

  def paid
    SalesInvoice.not_annulled.paid.includes(:payment)
                .where(issue_date: Date.new(@year, 1, 1)..Date.new(@year, 12, 31))
                .order(issue_date: :desc, number: :desc).to_a
  end

  def balances_by_number(numbers)
    Invoice.where(number: numbers).includes(income: :balance).each_with_object({}) do |invoice, result|
      balance = invoice.income&.balance
      next unless balance

      (result[invoice.number] ||= []) << { id: balance.id, client: balance.client, project: balance.project,
                                           editable: balance.editable, percentage: invoice.percentage.to_f }
    end
  end

  def serialize(invoice, percentage_used, balances)
    payment = invoice.payment
    {
      number: invoice.number,
      date: invoice.issue_date,
      dueDate: invoice.due_date,
      client: invoice.client_name,
      clientNit: invoice.client_nit,
      currency: invoice.currency,
      subtotal: invoice.subtotal.to_f,
      taxTotal: invoice.tax_total.to_f,
      total: invoice.total.to_f,
      suggestedRetentions: invoice.suggested_retentions,
      percentageUsed: percentage_used.round(2),
      balances: balances,
      lockedByClosedBalance: balances.any? { |balance| !balance[:editable] },
      payment: payment && {
        paidOn: payment.paid_on,
        amount: payment.amount&.to_f,
        retefuente: payment.retefuente.to_f,
        reteica: payment.reteica.to_f,
        reteiva: payment.reteiva.to_f,
        source: payment.source,
        registeredBy: payment.registered_by
      }
    }
  end
end
