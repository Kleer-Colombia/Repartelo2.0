# Impuestos y descuentos de una factura agregada a un balance, leídos de la
# factura del Drive (SalesInvoice). Las retenciones salen del pago cargado
# en Pagos; si todavía no está pagada, se agregan al registrar el pago
# (ver ApplyPaymentRetentions).
class CalculateTaxesInInvoice
  prepend Service

  attr_accessor :sales_invoice, :balance, :invoice, :trm

  def initialize(data)
    @sales_invoice = data[:sales_invoice]
    @balance = data[:balance]
    @invoice = data[:invoice]
    @trm = data[:trm]
  end

  def call
    Rails.logger.info("calculating taxes in invoices")
    @trm = @trm.to_f.positive? ? @trm.to_f : 1.0
    items = consolidate_items
    Rails.logger.info("items : #{items}")
    taxes = consolidate_taxes(items).values

    taxes += InvoiceRetentionTaxes.new(@invoice, @sales_invoice).build(@balance)

    save_taxes(taxes)
    save_discounts(items)

  rescue StandardError => error
    Rails.logger.error("#{error.class}: #{error.message}\n#{error.backtrace&.first(5)&.join("\n")}")
    errors.add(:messages, "error calculating invoice taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def save_taxes(taxes)
    Rails.logger.info("---before destroy taxes: #{@balance.taxes.map(&:name)}")
    @balance.taxes.where("invoice_id IS ?", nil).each(&:destroy)
    Rails.logger.info("---after destroy taxes: #{@balance.taxes.map(&:name)}")
    @balance.taxes += taxes
    @balance.taxes.each(&:save!)
    @balance.save!
    Rails.logger.info("---after taxes: #{@balance.taxes.map(&:name)}")
  end

  def save_discounts(items)
    total_discounts = 0
    items.each do |item|
      total_discounts+= item[:total_discount] * @trm
    end

    if(total_discounts > 0)
      @balance.expenses.create!(description: "Descuentos en factura #{@sales_invoice.number}",amount: total_discounts)
    end
  end

  # line_total ya viene neto de descuento (LineExtensionAmount del XML).
  def consolidate_items
    @sales_invoice.lines.map do |line|
      total_item = calculate_percentage(line['line_total'].to_f, @invoice.percentage)
      {
        total_item: total_item,
        total_discount: calculate_percentage(line['discount'].to_f, @invoice.percentage),
        taxes: (line['taxes'] || []).map do |tax|
          percentage = tax['percent'].to_f
          { name: tax['name'], percentage: percentage, amount: calculate_percentage(total_item, percentage) }
        end
      }
    end
  end

  def consolidate_taxes(items)
    taxes = {}
    items.each do |item|
      item[:taxes].each do |tax|
        name = tax[:name]
        amount = tax[:amount] * @trm
        percentage = tax[:percentage]
        if taxes[name]
          taxes[name].amount += amount
        else
          taxes[name] = Tax.new(name: name,
                                amount: amount,
                                percentage: percentage,
                                invoice: @invoice
                                )
        end
      end
    end
    taxes
  end

  #TODO duplicated
  def calculate_percentage(amount, percentage)
    ((amount * percentage.to_f)/100).round(2)
  end

end
