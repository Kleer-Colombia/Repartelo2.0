# Traduce los errores de validación de un Saldo a un mensaje en español para
# la pantalla (la app no tiene i18n configurado: los mensajes de Rails salen
# en inglés).
module SaldoErrors
  FIELDS = { amount: 'Monto', concept: 'Concepto', reference: 'Referencia', kleerer: 'Kleerer' }.freeze

  def self.message_for(record)
    faltan = []
    invalidos = []
    record.errors.details.each do |attr, details|
      name = FIELDS.fetch(attr, attr.to_s)
      details.each do |d|
        d[:error] == :blank ? faltan << name : invalidos << name
      end
    end
    partes = []
    partes << "Completá: #{faltan.uniq.join(', ')}" if faltan.any?
    partes << "Revisá: #{invalidos.uniq.join(', ')} (el monto no puede ser 0)" if invalidos.include?('Monto')
    partes << "Revisá: #{(invalidos.uniq - ['Monto']).join(', ')}" if (invalidos.uniq - ['Monto']).any?
    partes.empty? ? 'No se pudo guardar el registro.' : "No se pudo guardar el registro. #{partes.join('. ')}."
  end
end
