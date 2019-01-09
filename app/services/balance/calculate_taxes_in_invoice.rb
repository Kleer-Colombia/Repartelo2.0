class CalculateTaxesInInvoice
  prepend Service

  attr_accessor :invoice, @balance_id

  def initialize(data)
    @invoice = data[:invoice]
    @balance_id = data[:balance_id]
  end

  def call

    values = @invoice['items'].select do |item|
      total_item = calculate_total_item(item)
      taxes = find_taxes_per_item(item, total_item)
      {id: item['id'], total_item: total_item, taxes: taxes}
    end

    #TODO validar resultado y guardar los taxes unificados por nombre


  rescue StandardError => error
    errors.add(:messages, "error calculating invoice taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def is_valid?(taxes)
    total = 0
    taxes.each do |tax|
      total += tax[:amount]
    end
    total == @invoice['total']
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