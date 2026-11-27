require 'pdf-reader'

# Saca de una nota crédito en PDF las facturas que referencia. La DIAN
# obliga a que la nota crédito cite el CUFE de la factura (96 caracteres
# hexadecimales), así que buscarlo funciona con cualquier proveedor. Como
# respaldo también junta los números con prefijo (ej. FEKL10755).
class CreditNoteReader
  CUFE = /[0-9a-f]{96}/
  PREFIXED_NUMBER = /\b[A-Z]{2,6}\d{3,}\b/

  def self.references(pdf_bytes)
    text = PDF::Reader.new(StringIO.new(pdf_bytes)).pages.map(&:text).join("\n")
    {
      'cufes' => text.gsub(/\s+/, '').scan(CUFE).uniq,
      'numbers' => text.scan(PREFIXED_NUMBER).uniq
    }
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    raise DianDocumentParser::Error, "PDF ilegible: #{e.message}"
  end
end
