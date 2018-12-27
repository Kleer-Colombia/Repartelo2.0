class CalculateTaxes
  prepend Service

  attr_accessor :taxes, :expenses, :incomes, :save_in, :taxes_amounts, :taxes_percentages
  def initialize(data)
    @taxes = data[:taxes]
    @incomes = data[:incomes] ? data[:incomes] : 0
    @expenses = data[:expenses] ? data[:expenses] : 0
    @save_in = data[:save_in]
    @taxes_amounts = {}
    @taxes_percentages = {}
  end

  def call

    result = calculate_taxes(:invoiced, @incomes)
    pre_utility = calculate_utility(result)

    result = calculate_taxes(:utility, pre_utility)
    utility = calculate_utility(result)

    result = calculate_taxes(:post_utility, utility)
    utility = calculate_utility(result)

    save_taxes(result) if @save_in

    result['Ingresos'] = @incomes
    result['Egresos'] = @expenses
    result['Utilidad'] = utility

    result
  end

  private

  def save_taxes(taxes)
    taxes.each_with_index do |name, value|
      @save_in.taxes.create!(name: taxes[name],
                             amount: taxes[value],
                             percentage: @taxes_percentages[name])
    end
  end

  def calculate_taxes(type, amount)
    @taxes.each do |tax|
      if tax.type_tax == type.to_s
        @taxes_amounts[tax.name] = calculate_percentage(amount, tax.value)
        @taxes_percentages[tax.name] = tax.value
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