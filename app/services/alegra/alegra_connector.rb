require "base64"
require 'rest-client'

class AlegraConnector
  #TODO puts in ENV
  TOKEN = Base64.encode64('info@sparkta.co:d8a1429b1e0247f0e390')
  API_INVOICES = 'https://app.alegra.com/api/v1/invoices/'

  def self.get_invoices(status)
    response = RestClient.get("#{API_INVOICES}?status=#{status}", headers)
    raise StandardError.new("Error conectando con alegra: #{response.code}") unless response.code == 200
    JSON.parse(response.body)
  end

  def self.get_invoice(invoice_id)
    response = RestClient.get("#{API_INVOICES}?id=#{invoice_id}", headers)
    raise StandardError.new("Error conectando con alegra: #{response.code}") unless response.code == 200
    JSON.parse(response.body)[0]
  end

  private

  def self.headers
    {Authorization: "Basic #{TOKEN}"}
  end

end