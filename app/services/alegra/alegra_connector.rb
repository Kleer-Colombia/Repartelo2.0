require 'base64'

class AlegraConnector
  #TODO puts in ENV
  TOKEN = Base64.encode64('info@sparkta.co:d8a1429b1e0247f0e390')
  API_INVOICES = 'https://app.alegra.com/api/v1/invoices/'

  def self.get_invoices(status)
    response = connection.get("?status=#{status}")
    raise StandardError, "Error conectando con alegra: #{response.status}" unless response.status == 200
    JSON.parse(response.body)
  end

  def self.get_invoice(invoice_id)
    response = connection.get("?id=#{invoice_id}")
    raise StandardError, "Error conectando con alegra: #{response.status}" unless response.status == 200
    JSON.parse(response.body)[0]
  end

  private

  def self.headers
    {Authorization: "Basic #{TOKEN}"}
  end

  def self.connection
    conn = Faraday.new(url: API_INVOICES)
    conn.authorization :Basic, TOKEN
    conn
  end

end