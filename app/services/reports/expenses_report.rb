class ExpensesReport
  prepend Service

  def call

    attributes = %w{id balanceId descripcion valor creación}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Expense.all.sort_by{ |expense| expense.created_at }.each do |expense|
        csv << [expense.id, expense.balance_id, expense.description, expense.amount, expense.created_at]
      end
    end

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error generating expense report: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end