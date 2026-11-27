require 'pdf-reader'

# Saca de una nota crédito en PDF las facturas que referencia. La DIAN
# obliga a que la nota crédito cite el CUFE de la factura (96 caracteres
# hexadecimales), así que buscarlo funciona con cualquier proveedor. Como
# respaldo también junta los números con prefijo (ej. FEKL10755).
#
# El CUFE suele venir partido en varias líneas; al juntar el texto pueden
# quedar dígitos pegados (una fecha, un NIT), así que se devuelven todas las
# ventanas de 96 caracteres y la sincronización usa las que coinciden con
# una factura conocida.
#
# `annulment`: si es una nota de anulación (concepto DIAN 2, "Anulación de
# factura electrónica"). Las parciales (devolución, descuento, ajuste de
# precio) no anulan la factura.
class CreditNoteReader
  CUFE_WINDOWS = /(?=([0-9a-f]{96}))/
  PREFIXED_NUMBER = /\b[A-Z]{2,6}\d{3,}\b/
  ANNULMENT = /anulaci[oó]n/i

  def self.references(pdf_bytes)
    text = PDF::Reader.new(StringIO.new(pdf_bytes)).pages.map(&:text).join("\n")
    {
      'cufes' => text.gsub(/\s+/, '').scan(CUFE_WINDOWS).flatten.uniq,
      'numbers' => text.scan(PREFIXED_NUMBER).uniq,
      'annulment' => text.match?(ANNULMENT)
    }
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    raise DianDocumentParser::Error, "PDF ilegible: #{e.message}"
  end
end
