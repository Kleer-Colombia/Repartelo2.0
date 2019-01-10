class CalculateTaxesInInvoice
  prepend Service

  attr_accessor :invoice, @balance

  def initialize(data)
    @invoice = data[:invoice]
    @balance = data[:balance]
  end

  def call
    items = consolidate_items
    taxes = consolidate_taxes(items).values
    save_taxes(taxes)

  rescue StandardError => error
    errors.add(:messages, "error calculating invoice taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def save_taxes(taxes)
    @balance.taxes -= @balance.find_other_taxes
    @balance.taxes + taxes
    @balance.save!
  end

  def consolidate_items
    @invoice['items'].select do |item|
      total_item = calculate_total_item(item)
      taxes = find_taxes_per_item(item, total_item)
      {id: item['id'], total_item: total_item, taxes: taxes}
    end
  end

  def consolidate_taxes(items)
    taxes = {}
    items.each do |item|
      name = item[:taxes][:name]
      amount = item[:taxes][:amount]
      percentage = item[:taxes][:percentage]
      if taxes[name]
        taxes[name].amount += amount
      else
        taxes[name] = Tax.new(name: name,
                              amount: amount,
                              percentage: percentage)
      end
    end
  end

  def find_taxes_per_item(item, total_item)
    item['taxes'].select do |tax|
      percentage = tax['percentage'].to_f
      { name: tax['name'],
        percentage: percentage,
        amount: calculate_percentage(total_item, percentage)
      }
    end
  end

  def calculate_total_item(item)
    item['price'] * item['quantity']
  end

  def calculate_percentage(amount, percentage)
    ((amount * percentage)/100).round(2)
  end

end