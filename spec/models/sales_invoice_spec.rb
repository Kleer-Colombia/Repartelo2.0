require 'rails_helper'

describe SalesInvoice do
  describe '.retention_kind_for' do
    {
      'ReteIVA' => 'reteiva',
      'Reteiva 11% - Especial' => 'reteiva',
      'Reteica Bogotá 2022' => 'reteica',
      'RETEICA MEDELLIN' => 'reteica',
      'Reteica 11.04' => 'reteica',
      'Honorarios y comisiones' => 'retefuente',
      'Servicios 1.5%' => 'retefuente',
      'Servicios de consultoría administrativa' => 'retefuente',
      'Servicios de aseo y vigilancia' => 'retefuente'
    }.each do |name, kind|
      it "#{name} → #{kind}" do
        expect(SalesInvoice.retention_kind_for(name)).to eq kind
      end
    end
  end
end
