class SaldosReport
  prepend Service

  def call

    attributes = %w{id Kleerer amount concepto referencia creación}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Saldo.order(:kleerer_id,:created_at).each do |saldo|
        csv << [saldo.id, saldo.kleerer.name, saldo.amount, saldo.concept, saldo.reference, saldo.created_at]
      end
    end

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error generating expense report: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end