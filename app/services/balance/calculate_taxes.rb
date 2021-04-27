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
    Rails.logger.info("incomes: #{@incomes}")
    result = calculate_taxes(:invoiced, @incomes)

    resume_in_invoice = adjust_incomes_with_in_invoice_taxes if @save_in

    result.merge!(calculate_taxes(:post_iva, @incomes))

    pre_utility = calculate_utility(result)

    result = calculate_taxes(:utility, pre_utility)
    utility = calculate_utility(result)

    result = calculate_taxes(:post_utility, utility)
    utility = calculate_utility(result)

    save_taxes(result) if @save_in

    result['Ingresos'] = @incomes
    result['Egresos'] = @expenses
    result['Utilidad'] = utility

    Rails.logger.info("Resumed taxes: #{result}")

    @save_in ? @save_in.resume : result
  end

  private

  def adjust_incomes_with_in_invoice_taxes
    resume_in_invoice, total_taxes_in_invoice = @save_in.resume_in_invoice_tax
    @incomes -= total_taxes_in_invoice
    resume_in_invoice
  end

  def save_taxes(taxes)
    @save_in.taxes -= @save_in.find_master_taxes
    taxes.each do |name, value|
      @save_in.taxes.push(Tax.new(name: name,
                                  amount: value,
                                  percentage: @taxes_percentages[name]))
    end
    @save_in.save!
  end

  def calculate_taxes(type, amount)
    Rails.logger.info("calculate taxes: #{type}, #{amount}")
    @taxes.each do |tax|

      if tax.type_tax == type.to_s
        Rails.logger.info("tax type: #{tax.type_tax}")
        @taxes_amounts[tax.name] = calculate_percentage(amount, tax.value)
        @taxes_percentages[tax.name] = tax.value
      end
    end
    Rails.logger.info("taxes amounts: #{@taxes_amounts}")
    Rails.logger.info("taxes percentages: #{@taxes_percentages}")
    @taxes_amounts
  end

  # TODO duplicated in calculate taxes in invoice, put in utils.
  def calculate_percentage(amount, percentage)
    ((amount * percentage) / 100).round(2)
  end

  def calculate_utility(taxes_amount)
    taxes_total = 0
    Rails.logger.info("calculate utility: #{taxes_amount}")
    taxes_amount.each do |tax_amount|
      taxes_total += tax_amount[1]
    end
    utility = @incomes - taxes_total - @expenses
    Rails.logger.info("utility: #{utility}")
    utility
  end
end
