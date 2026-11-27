require 'rails_helper'

describe DianDocumentParser do
  let(:attached) { file_fixture('dian/attached_invoice.xml').read }

  it 'lee la factura embebida en el AttachedDocument' do
    result = DianDocumentParser.parse(attached)
    attrs = result.attributes

    expect(result.kind).to eq :invoice
    expect(attrs[:number]).to eq 'TEST900'
    expect(attrs[:supplier_nit]).to eq '900957609'
    expect(attrs[:cufe]).to eq 'a' * 96
    expect(attrs[:issue_date]).to eq Date.new(2026, 11, 3)
    expect(attrs[:due_date]).to eq Date.new(2026, 12, 3)
    expect(attrs[:currency]).to eq 'USD'
    expect(attrs[:exchange_rate]).to eq 4000
    expect(attrs[:client_name]).to eq 'CLIENTE DE PRUEBA S.A.S.'
    expect(attrs[:client_nit]).to eq '800000001'
    expect(attrs[:subtotal]).to eq 900
    expect(attrs[:tax_total]).to eq 171
    expect(attrs[:total]).to eq 1071
  end

  it 'lee ítems con descuento e IVA' do
    line = DianDocumentParser.parse(attached).attributes[:lines].first

    expect(line).to include('description' => 'Taller de prueba', 'quantity' => 2.0, 'price' => 500.0,
                            'line_total' => 900.0, 'discount' => 100.0)
    expect(line['taxes']).to eq [{ 'name' => 'IVA', 'percent' => 19.0, 'amount' => 171.0 }]
  end

  it 'toma las retenciones si el XML las informa (como sugerencia)' do
    expect(DianDocumentParser.parse(attached).attributes[:suggested_retentions]).to eq('retefuente' => 99.0)
  end

  it 'lee la factura anulada que referencia una nota crédito' do
    result = DianDocumentParser.parse(file_fixture('dian/credit_note.xml').read)

    expect(result.kind).to eq :credit_note
    expect(result.references).to eq('cufes' => ['a' * 96], 'numbers' => ['TEST900'])
  end

  it 'falla con un XML inválido' do
    expect { DianDocumentParser.parse('no es xml') }.to raise_error(DianDocumentParser::Error)
  end
end
