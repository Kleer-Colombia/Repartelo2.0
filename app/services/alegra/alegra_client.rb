require 'base64'

class AlegraClient

  TOKEN = Base64.strict_encode64("#{ENV['ALEGRA_EMAIL']}:#{ENV['ALEGRA_TOKEN']}")
  API_INVOICES = 'https://app.alegra.com/api/v1/invoices/'

  def get_invoices(status)
    response = connection.get("?status=#{status}")
    raise StandardError, "Error conectando con alegra: #{response.status}" unless response.status == 200
    JSON.parse(response.body)
  end

  def get_invoice(invoice_id)
    response = connection.get("?id=#{invoice_id}")
    raise StandardError, "Error conectando con alegra: #{response.status}" unless response.status == 200
    JSON.parse(response.body)[0]
  end

  def is_invoice_closed?(invoice_id)
    invoice = get_invoice(invoice_id)
    invoice['status'] == 'closed'
  end

  private

  def headers
    {Authorization: "Basic #{TOKEN}"}
  end

  def connection
    conn = Faraday.new(url: API_INVOICES)
    conn.authorization :Basic, TOKEN
    conn
  end

end
