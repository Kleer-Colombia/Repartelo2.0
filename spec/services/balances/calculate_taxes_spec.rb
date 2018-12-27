require 'rails_helper'

describe CalculateTaxes do

  before(:each) do
    @ica = TaxMaster.new(name: 'ica',
                         value: 1.1,
                         type_tax: :invoiced)

    @chanchito = TaxMaster.new(name: 'chanchito',
                               value: 2.5,
                               type_tax: :invoiced)
    @retefuente = TaxMaster.new(name: 'retefuente',
                                value: 17,
                                type_tax: :utility)
    @kleerCo = TaxMaster.new(name: 'kleerCo',
                             value: 10,
                             type_tax: :post_utility)

  end

  it 'should calculate chanchito' do

    allow(TaxMaster).to receive(:all).and_return([@chanchito])

    cib = CalculateTaxes.new(taxes: TaxMaster.all, incomes: 1000000)
    cib.call
    expect(cib.result['chanchito']).to eq 25000
    expect(cib.result['Utilidad']).to eq 975000

  end

  it 'should calculate chanchito and Ica' do
    allow(TaxMaster).to receive(:all).and_return([@chanchito, @ica])

    cib = CalculateTaxes.new(taxes: TaxMaster.all, incomes: 3000000)
    cib.call
    expect(cib.result['chanchito']).to eq 75000
    expect(cib.result['ica']).to eq 33000
    expect(cib.result['Utilidad']).to eq 2892000

  end

  it 'should calculate Ica, chanchito with expensives' do
    allow(TaxMaster).to receive(:all).and_return([@chanchito, @ica])

    cib = CalculateTaxes.new(taxes: TaxMaster.all, incomes: 1234567, expenses: 8912)
    cib.call
    expect(cib.result['chanchito']).to eq 30864.18
    expect(cib.result['ica']).to eq 13580.24
    expect(cib.result['Utilidad']).to eq 1181210.58

  end

  it 'should calculate Ica, chanchito and retefuente with expensives' do
    allow(TaxMaster).to receive(:all).and_return([@chanchito, @ica, @retefuente])
    cib = CalculateTaxes.new(taxes: TaxMaster.all, incomes: 100000, expenses: 1000)
    cib.call

    expect(cib.result['chanchito']).to eq 2500
    expect(cib.result['ica']).to eq 1100
    expect(cib.result['retefuente']).to eq 16218
    expect(cib.result['Utilidad']).to eq 79182

  end


  it 'should calculate Ica, chanchito, retefuente and KleerCo' do
    allow(TaxMaster).to receive(:all).and_return([@ica, @chanchito, @retefuente, @kleerCo])

    cib = CalculateTaxes.new(taxes: TaxMaster.all, incomes: 100000)
    cib.call

    expect(cib.result['chanchito']).to eq 2500
    expect(cib.result['ica']).to eq 1100
    expect(cib.result['retefuente']).to eq 16388
    expect(cib.result['kleerCo']).to eq 8001.2
    expect(cib.result['Utilidad']).to eq 72010.80

  end

end