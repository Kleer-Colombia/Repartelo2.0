# Cliente de la API de Alegra. Repártelo ya no consulta Alegra en el uso
# diario (las facturas vienen del Drive de contabilidad); queda solo para la
# migración inicial: `bin/rails facturas:migrar_alegra` (lib/tasks/facturas.rake).
class AlegraClient
  API_INVOICES = 'https://app.alegra.com/api/v1/invoices/'.freeze
  PAGE_SIZE = 30 # máximo que acepta la API

  def self.configured?
    ENV['ALEGRA_EMAIL'].present? && ENV['ALEGRA_TOKEN'].present?
  end

  # Recorre todas las facturas (todas las páginas), de la más vieja a la más nueva.
  def each_invoice
    return enum_for(:each_invoice) unless block_given?

    start = 0
    loop do
      page = get(start: start, limit: PAGE_SIZE, order_field: 'id', order_direction: 'ASC')
      page.each { |invoice| yield invoice }
      break if page.size < PAGE_SIZE

      start += PAGE_SIZE
      sleep 0.3 # la API limita pedidos por minuto
    end
  end

  private

  def get(params)
    response = connection.get('', params)
    raise StandardError, "Error conectando con Alegra: #{response.status}" unless response.status == 200

    JSON.parse(response.body)
  end

  def connection
    @connection ||= Faraday.new(url: API_INVOICES) do |conn|
      conn.basic_auth(ENV.fetch('ALEGRA_EMAIL'), ENV.fetch('ALEGRA_TOKEN'))
      conn.adapter Faraday.default_adapter
    end
  end
end
