# Facturas que se pueden agregar a un balance ("Buscar factura"): las de los
# últimos INVOICE_LOOKBACK_MONTHS meses (12 por defecto) no anuladas y no
# usadas al 100%, más las usadas en parte aunque sean más viejas. Antes de
# responder trae del Drive lo nuevo, si la última sincronización es vieja.
class FindAvailableInvoices
  prepend Service

  DEFAULT_MONTHS = 12

  attr_reader :sync

  def initialize(data = {})
    @sync = data.fetch(:sync, true)
  end

  def call
    run = DriveInvoiceSync.run_if_stale if @sync
    used = Invoice.used_percentages
    partial = used.select { |_, pct| pct < 100 }.keys

    scope = SalesInvoice.not_annulled.includes(:payment)
    invoices = scope.where('issue_date >= ?', months.months.ago.to_date).or(scope.where(number: partial))
                    .order(issue_date: :desc, number: :desc)
                    .reject { |invoice| used.fetch(invoice.number, 0) >= 100 }

    { invoices: invoices.map { |invoice| serialize(invoice, used.fetch(invoice.number, 0)) },
      months: months,
      lastSync: (run || DriveSyncRun.last_finished)&.as_summary }
  rescue StandardError => e
    Rails.logger.error("[FindAvailableInvoices] #{e.class}: #{e.message}")
    errors.add(:messages, "error buscando facturas: #{e.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def months
    value = ENV['INVOICE_LOOKBACK_MONTHS'].to_i
    value.positive? ? value : DEFAULT_MONTHS
  end

  def serialize(invoice, percentage_used)
    {
      number: invoice.number,
      date: invoice.issue_date,
      dueDate: invoice.due_date,
      client: invoice.client_name,
      total: invoice.total.to_f,
      currency: invoice.foreign_currency? ? invoice.currency : nil,
      exchangeRate: invoice.exchange_rate&.to_f,
      percentageUsed: percentage_used.round(2),
      paid: invoice.paid?
    }
  end
end
