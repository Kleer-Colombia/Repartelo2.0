class CalculateTaxesInInvoice
  prepend Service

  attr_accessor :invoice, :balance, :invoice_percentage

  def initialize(data)
    @invoice = data[:invoice]
    @balance = data[:balance]
    @invoice_percentage = data[:invoice_percentage]
  end

  def call
    items = consolidate_items
    taxes = consolidate_taxes(items).values
    save_taxes(taxes)

  rescue StandardError => error
    puts error
    errors.add(:messages, "error calculating invoice taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def save_taxes(taxes)
    Tax.where("invoice_id = #{@invoice['id']} and balance_id = #{@balance.id}").destroy_all
    @balance.taxes += taxes
    @balance.save!
  end

  def consolidate_items
    @invoice['items'].map do |item|
      total_item = calculate_total_item(item)
      taxes = find_taxes_per_item(item, total_item)
      {id: item['id'], total_item: total_item, taxes: taxes}
    end

  end

  def consolidate_taxes(items)
    taxes = {}
    items.each do |item|
      item[:taxes].each do |tax|
        name = tax[:name]
        amount = tax[:amount]
        percentage = tax[:percentage]
        if taxes[name]
          taxes[name].amount += amount
        else
          taxes[name] = Tax.new(name: name,
                                amount: amount,
                                percentage: percentage,
                                invoice_id: @invoice['id'],
                                invoice_date: @invoice['date'])
        end
      end
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
    one_hundred_total = item['price'] * item['quantity'].to_f
    total_for_balance = calculate_percentage(one_hundred_total,@invoice_percentage)
    total_for_balance
  end

  def calculate_percentage(amount, percentage)
    ((amount * percentage)/100).round(2)
  end

end