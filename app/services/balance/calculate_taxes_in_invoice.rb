class CalculateTaxesInInvoice
  prepend Service

  attr_accessor :alegra_invoice, :balance, :invoice, :trm

  def initialize(data)
    @alegra_invoice = data[:alegra_invoice]
    @balance = data[:balance]
    @invoice = data[:invoice]
    @trm = data[:trm]
  end

  def call

    Rails.logger.info("calculating taxes in invoices")
    items = consolidate_items
    Rails.logger.info("items : #{items}")
    taxes = consolidate_taxes(items).values

    taxes += add_invoice_taxes(@alegra_invoice).values
    Rails.logger.info("taxes: #{taxes}")
    save_taxes(taxes)
    save_discounts(items)

  rescue StandardError => error
    puts error
    puts error.backtrace
    errors.add(:messages, "error calculating invoice taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def save_taxes(taxes)
    @invoice.taxes.each(&:destroy)
    @balance.taxes += taxes
    @balance.save!
  end

  def save_discounts(items)
    total_discounts = 0
    items.each do |item|
      total_discounts+= item[:total_discount]
    end

    if(total_discounts > 0)
      @balance.expenses.create!(description: "Descuentos en factura #{@alegra_invoice["id"]}",amount: total_discounts)
    end
  end

  def consolidate_items
    @alegra_invoice['items'].map do |item|
      item_summary = calculate_total_item(item)
      item_summary[:taxes]  = find_taxes_per_item(item, item_summary[:total_item])

      item_summary
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

  def add_invoice_taxes(invoice)
    taxes = {}
    invoice['retentions'].each do |retention|
      taxes[retention['name']] = Tax.new(name: retention['name'],
              amount: calculate_percentage( retention['amount'].to_f * @trm,@invoice.percentage),
              percentage: retention['percentage'],
              invoice: @invoice)
    end
    taxes
  end

  def find_taxes_per_item(item, total_item)
    item['tax'].map do |tax|
      percentage = tax['percentage'].to_f
      { name: tax['name'],
        percentage: percentage,
        amount: calculate_percentage(total_item, percentage)
      }
    end
  end

  def calculate_total_item(item)
    item_summary = {id: item['id']}
    discount_factor = 1
    if item['discount'].to_f > 0
      discount_factor -= (item['discount'].to_f/100)
    end

    one_hundred_total = item['price'] * item['quantity'].to_f * discount_factor
    discount_total = item['price'] * item['quantity'].to_f * (1-discount_factor)
    total_for_balance = calculate_percentage(one_hundred_total,@invoice.percentage)
    discount_total_for_balance = calculate_percentage(discount_total,@invoice.percentage)
    item_summary[:total_item] = total_for_balance
    item_summary[:total_discount] = discount_total_for_balance
    item_summary[:discount] = item['discount'].to_f

    item_summary
  end

  #TODO duplicated
  def calculate_percentage(amount, percentage)
    ((amount * percentage)/100).round(2)
  end

end