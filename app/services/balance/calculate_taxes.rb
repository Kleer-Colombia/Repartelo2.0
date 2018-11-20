class CalculateTaxes
  prepend Service

  attr_accessor :invoice, :taxes, :expenses, :incomes, :taxes_amounts

  def initialize(data)
    @invoice = data[:invoice]
    @taxes = data[:taxes]
    data[:incomes] ? @incomes = data[:incomes] : @incomes = 0
    data[:expenses] ? @expenses = data[:expenses] : @expenses = 0
    @taxes_amounts = {}
  end

  def call
    @incomes = @invoice[:total] + @incomes
    result = calculate_taxes(:invoiced, @incomes)
    pre_utility = calculate_utility(result)
    result = calculate_taxes(:utility , pre_utility)
    result[:utility] = calculate_utility(result)
    return result
  end

  private

  def calculate_taxes (type, amount)
    @taxes.each do |tax|
      if tax[:type] == type
        @taxes_amounts[tax[:name]] = calculate_percentage(amount, tax[:value])
      end
    end
    @taxes_amounts
  end

  def calculate_percentage(amount, percentage)
    ((amount * percentage)/100).round(2)
  end

  def calculate_utility(taxes_amount)
    taxes_total = 0
    taxes_amount.each do |tax_amount|
      taxes_total += tax_amount[1]
    end
    utility = @incomes - taxes_total - @expenses
    utility
  end


end