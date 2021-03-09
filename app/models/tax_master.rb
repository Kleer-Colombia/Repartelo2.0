class TaxMaster < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true
  validates :type_tax, presence: true
  has_many :manual_taxes

  INVOICE_TAX_GROUPS = {
    IVA: ['iva','IVA'],
    RETEIVA: ['ReteIVA', 'Reteiva 11% - Especial','RETEIVA'],
    RETEICA: ['RETEICABOGOTA','RETEICA_MEDELLIN','RETEICA MEDELLIN','RETEICA BOG2','ReteICA Cali', 'RETEICA'],
    RETEFUENTE: ['Arrendamiento de bienes muebles',
                  'Arrendamiento de bienes raíces',
                'Compras',
                'Honorarios y comisiones',
                'Servicios de aseo y vigilancia',
                'Servicios de hoteles y restaurantes',
                'Servicios en general',
                'Servicios en general',
                'Transporte de carga',
                'Retefuente Mexico',
                'Honorarios en Perú',
                'Honorarios Argentina',
                 'RETEFUENTE'
                ]
  }

  def self.translate_tax_name (in_invoice_tax_name)
    traslated_name = ""
    INVOICE_TAX_GROUPS.each do |new_name, values|
      if values.include? in_invoice_tax_name
        traslated_name = new_name
        break
      end
    end
    Rails.logger.info("traslated #{in_invoice_tax_name} => #{traslated_name}")
    traslated_name
  end

  def self.find_taxes(type)
    where(type_tax: type)
  end

  def self.taxes_names_to_calculate
    where.not(type_tax: 'in_alegra').map(&:name)
  end

  def self.taxes_to_show
    where.not(name: 'kleerCo')
  end

  def self.all_taxes(balance)

    if balance.balance_type == 'standard-international'
      master_taxes = where.not(name: 'Ica')
      master_taxes.each do |master_tax|
        if master_tax.name == 'Retefuente'
          master_tax.value = balance.retencion
        end
      end
    else
      master_taxes = all
    end
    return master_taxes
  end


end
