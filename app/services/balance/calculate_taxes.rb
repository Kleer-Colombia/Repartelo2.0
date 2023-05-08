class CalculateTaxes
  prepend Service

  attr_accessor :taxes,:total_clearings, :clearings, :expenses, :incomes, :save_in, :taxes_amounts, :taxes_percentages, :incomes_post_iva, :iva
  def initialize(data)
    @taxes = data[:taxes]
    @incomes = data[:incomes] ? data[:incomes] : 0
    @incomes_post_iva = data[:incomes_post_iva] ? data[:incomes_post_iva] : 0
    @expenses = data[:expenses] ? data[:expenses] : 0
    @clearings = data[:clearings] ? data[:clearings] : []
    @total_clearings = data[:total_clearings] ? data[:total_clearings] : 0
    @save_in = data[:save_in]
    @iva = data[:iva] ? data[:iva] : 0
    @taxes_amounts = {}
    @taxes_percentages = {}
  end

  def call
    Rails.logger.info("incomes: #{@incomes}")
    incomes_without_iva = @incomes - @iva
    result = calculate_taxes(:invoiced, @incomes)[0]

    resume_in_invoice = {}
    resume_in_invoice.merge!(adjust_incomes_with_in_invoice_taxes) if @save_in

    retefuente = resume_in_invoice["RETEFUENTE"] != nil ? resume_in_invoice["RETEFUENTE"] :0
    reteica = resume_in_invoice["RETEICA"] != nil ? resume_in_invoice["RETEICA"] :0

    result.merge!(calculate_taxes(:post_iva, incomes_without_iva)[0])

    set_clearings_amounts(calculate_base(@incomes - @expenses, result))
    clearings = calculate_clearings(calculate_base(@incomes - @expenses, result))
    @incomes -= clearings

    pre_utility = calculate_utility(result)

    result, reservas_result = calculate_taxes(:reservas, incomes_without_iva - clearings)

    reservas_result.each do |key, value|
      if value > (pre_utility)
        reservas_result[key] = 0
        result[key] = 0
      end
    end

    result.merge!(calculate_taxes(:utility, pre_utility  - calculate_tax_total(reservas_result))[0])

    utility = calculate_utility(result)

    result.merge!(calculate_taxes(:post_utility, utility)[0])

    utility = calculate_utility(result)
    save_taxes(result) if @save_in
    result['Ingresos'] = @incomes
    result['Egresos'] = @expenses
    result['Utilidad'] = utility
    result['Clearings'] = clearings

    Rails.logger.info("Resumed taxes: #{result}")

    @save_in ? @save_in.resume : result
  end

  private

  def adjust_incomes_with_in_invoice_taxes
    resume_in_invoice, total_taxes_in_invoice = @save_in.resume_in_invoice_tax
    @incomes -= total_taxes_in_invoice
    return resume_in_invoice
  end

  def save_taxes(taxes)
    Rails.logger.info("actual taxes: #{@save_in.taxes.map(&:name)}")
    @save_in.taxes -= @save_in.find_master_taxes
    Rails.logger.info("after remove master taxes: #{@save_in.taxes.map(&:name)}")
    taxes.each do |name, value|
      @save_in.taxes.push(Tax.new(name: name,
                                  amount: value,
                                  percentage: @taxes_percentages[name]))
    end
    @save_in.save!
  end

  def calculate_taxes(type, amount)
    Rails.logger.info("calculate taxes: #{type}, #{amount}")
    taxes_by_type = {}
    @taxes.each do |tax|

      if tax.type_tax == type.to_s
        Rails.logger.info("tax type: #{tax.type_tax}")
        @taxes_amounts[tax.name] = calculate_percentage(amount, tax.value)
        @taxes_percentages[tax.name] = tax.value
        if amount < 0
          @taxes_amounts[tax.name] = 0
        end
        taxes_by_type[tax.name] = calculate_percentage(amount, tax.value)
      end
    end
    Rails.logger.info("taxes amounts: #{@taxes_amounts}")
    Rails.logger.info("taxes percentages: #{@taxes_percentages}")
    return @taxes_amounts, taxes_by_type
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

  def calculate_clearings(base)
    total = @total_clearings * base
  end

  def calculate_tax_total(taxes)
    total = 0
    taxes.each do |tax_amount|
      total += tax_amount[1]
    end

    total
  end

  def calculate_base(total, taxes)
    new_total = total
    taxes.each do |tax_amount|
      new_total -= tax_amount[1]
    end
    new_total
  end

  def set_clearings_amounts(base)
    @clearings.each do |e|
      e.amount = base * e.percentage
      e.save!
    end
  end
end
