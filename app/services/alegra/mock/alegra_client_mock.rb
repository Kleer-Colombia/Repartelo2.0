
class AlegraClientMock
  def get_invoices(status)
    data = File.read("#{__dir__}/531.json")
    [JSON.parse(data)]
  end

  def get_invoice(invoice_id)
    data = File.read("#{__dir__}/#{invoice_id}.json")
    JSON.parse(data)
  end
end