require 'rails_helper'

describe CreditNoteReader do
  def references_for(text)
    pages = [double(text: text)]
    allow(PDF::Reader).to receive(:new).and_return(double(pages: pages))
    CreditNoteReader.references('%PDF')
  end

  let(:cufe) { 'c' * 48 + 'd' * 48 }

  it 'encuentra el CUFE partido en líneas aunque tenga dígitos pegados' do
    refs = references_for("Fecha: 2026-11-10\n#{cufe[0, 50]}\n#{cufe[50..]}\nAnulación de factura electrónica")
    expect(refs['cufes']).to include(cufe)
    expect(refs['annulment']).to be true
  end

  it 'distingue una nota parcial y toma los números con prefijo como respaldo' do
    refs = references_for('Devolución parcial - Factura electrónica: FEKL10755')
    expect(refs['annulment']).to be false
    expect(refs['numbers']).to eq ['FEKL10755']
  end
end
