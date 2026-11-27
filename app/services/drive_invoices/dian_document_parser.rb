# Lee un XML de factura electrónica DIAN (UBL 2.1). Acepta el
# AttachedDocument que entregan los proveedores (Alegra, Contapyme, ...)
# con la factura embebida, o la factura sola. El formato lo define la DIAN,
# así que no depende del proveedor de facturación.
class DianDocumentParser
  class Error < StandardError; end

  Result = Struct.new(:kind, :attributes, :references, keyword_init: true)

  INVOICE_ROOTS = %w[Invoice].freeze
  CREDIT_NOTE_ROOTS = %w[CreditNote].freeze

  def self.parse(xml)
    new(xml).parse
  end

  def initialize(xml)
    @xml = xml
  end

  def parse
    root = document_root(load_xml(@xml))
    if INVOICE_ROOTS.include?(root.name)
      Result.new(kind: :invoice, attributes: invoice_attributes(root))
    elsif CREDIT_NOTE_ROOTS.include?(root.name)
      Result.new(kind: :credit_note, references: credit_note_references(root))
    else
      Result.new(kind: :other)
    end
  end

  private

  # Estricto: un XML roto es un error (se reintenta), no un documento
  # "reparado". Nokogiri no resuelve entidades externas ni accede a la red
  # por defecto (sin NOENT/DTDLOAD); `nonet` lo deja explícito.
  def load_xml(text)
    doc = Nokogiri::XML(text.to_s) { |config| config.strict.nonet }
    raise Error, 'XML vacío' if doc.root.nil?

    doc.remove_namespaces!
    doc
  rescue Nokogiri::XML::SyntaxError => e
    raise Error, "XML inválido: #{e.message}"
  end

  def document_root(doc)
    root = doc.root
    return root unless root.name == 'AttachedDocument'

    embedded = root.xpath('.//Attachment//Description').map(&:text).find do |text|
      text.include?('<Invoice') || text.include?('<CreditNote')
    end
    raise Error, 'AttachedDocument sin factura ni nota crédito embebida' unless embedded

    load_xml(embedded).root
  end

  def invoice_attributes(root)
    currency = text(root, './DocumentCurrencyCode').presence || 'COP'
    {
      number: required(root, './ID'),
      supplier_nit: text(root, './AccountingSupplierParty/Party/PartyTaxScheme/CompanyID').presence ||
        text(root, './AccountingSupplierParty/Party/PartyLegalEntity/CompanyID'),
      cufe: text(root, './UUID'),
      type_code: text(root, './InvoiceTypeCode'),
      issue_date: Date.parse(required(root, './IssueDate')),
      due_date: date(text(root, './DueDate').presence || text(root, './PaymentMeans/PaymentDueDate')),
      currency: currency,
      exchange_rate: currency == 'COP' ? nil : decimal(text(root, './PaymentExchangeRate/CalculationRate')),
      client_name: customer_name(root),
      client_nit: text(root, './AccountingCustomerParty/Party/PartyTaxScheme/CompanyID').presence ||
        text(root, './AccountingCustomerParty/Party/PartyLegalEntity/CompanyID'),
      subtotal: decimal(text(root, './LegalMonetaryTotal/LineExtensionAmount')) || 0,
      tax_total: root.xpath('./TaxTotal/TaxAmount').sum { |node| decimal(node.text) || 0 },
      total: decimal(text(root, './LegalMonetaryTotal/PayableAmount')) || 0,
      lines: root.xpath('./InvoiceLine').map { |line| line_attributes(line) },
      suggested_retentions: withholdings(root)
    }
  end

  def customer_name(root)
    party = './AccountingCustomerParty/Party'
    text(root, "#{party}/PartyTaxScheme/RegistrationName").presence ||
      text(root, "#{party}/PartyLegalEntity/RegistrationName").presence ||
      text(root, "#{party}/PartyName/Name")
  end

  def line_attributes(line)
    {
      'description' => text(line, './Item/Description').presence || text(line, './Item/Name'),
      'quantity' => decimal(text(line, './InvoicedQuantity')) || 1,
      'price' => decimal(text(line, './Price/PriceAmount')) || 0,
      'line_total' => decimal(text(line, './LineExtensionAmount')) || 0,
      'discount' => line.xpath('./AllowanceCharge').sum do |charge|
        text(charge, './ChargeIndicator') == 'false' ? (decimal(text(charge, './Amount')) || 0) : 0
      end,
      'taxes' => line.xpath('./TaxTotal/TaxSubtotal').map do |subtotal|
        {
          'name' => text(subtotal, './TaxCategory/TaxScheme/Name').presence || text(subtotal, './TaxCategory/TaxScheme/ID'),
          'percent' => decimal(text(subtotal, './TaxCategory/Percent').presence || text(subtotal, './Percent')) || 0,
          'amount' => decimal(text(subtotal, './TaxAmount')) || 0
        }
      end
    }.transform_values { |value| value.is_a?(BigDecimal) ? value.to_f : value }
  end

  # Retenciones informadas en la factura (opcionales en el anexo técnico
  # DIAN; Alegra no las incluye). Códigos DIAN: 05 ReteIVA, 06 ReteRenta
  # (Retefuente), 07 ReteICA.
  def withholdings(root)
    result = {}
    root.xpath('./WithholdingTaxTotal/TaxSubtotal').each do |subtotal|
      code = text(subtotal, './TaxCategory/TaxScheme/ID')
      name = text(subtotal, './TaxCategory/TaxScheme/Name').to_s
      kind = { '05' => 'reteiva', '06' => 'retefuente', '07' => 'reteica' }[code] || SalesInvoice.retention_kind_for(name)
      result[kind] = (result[kind] || 0) + (decimal(text(subtotal, './TaxAmount')) || 0).to_f
    end
    result
  end

  def credit_note_references(root)
    refs = root.xpath('./BillingReference/InvoiceDocumentReference')
    {
      'cufes' => refs.map { |ref| text(ref, './UUID') }.reject(&:blank?),
      'numbers' => refs.map { |ref| text(ref, './ID') }.reject(&:blank?)
    }
  end

  def text(node, path)
    node.at_xpath(path)&.text.to_s.strip
  end

  def required(node, path)
    value = text(node, path)
    raise Error, "falta #{path} en el XML" if value.empty?

    value
  end

  def decimal(value)
    return nil if value.blank?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end

  def date(value)
    value.present? ? Date.parse(value) : nil
  rescue ArgumentError
    nil
  end
end
