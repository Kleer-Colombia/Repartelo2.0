require 'rails_helper'

describe CalculateTaxes do

  before(:each) do
    @ica = { name: :ica,
            value: 1.1,
            type: :invoiced
    }
    @chanchito = { name: :chanchito,
            value: 2.5,
            type: :invoiced
    }
    @retefuente = { name: :retefuente,
            value: 17,
            type: :utility
    }

  end

  it 'should calculate chanchito' do

    cib = CalculateTaxes.new(taxes: [@chanchito], invoice: {total: 1000000})
    cib.call
    expect(cib.result[:chanchito]).to eq 25000
    expect(cib.result[:utility]).to eq 975000

  end

  it 'should calculate chanchito and Ica' do

    cib = CalculateTaxes.new(taxes: [@chanchito, @ica], invoice: {total: 3000000})
    cib.call
    expect(cib.result[:chanchito]).to eq 75000
    expect(cib.result[:ica]).to eq 33000
    expect(cib.result[:utility]).to eq 2892000

  end

  it 'should calculate Ica, chanchito with expensives' do

    cib = CalculateTaxes.new(taxes: [@ica, @chanchito], invoice: {total: 1234567}, expenses: 8912)
    cib.call
    expect(cib.result[:chanchito]).to eq 30864.18
    expect(cib.result[:ica]).to eq 13580.24
    expect(cib.result[:utility]).to eq 1181210.58

  end

  it 'should calculate Ica, chanchito and retefuente with expensives' do

    cib = CalculateTaxes.new(taxes: [@ica, @chanchito, @retefuente], invoice: {total: 100000}, expenses: 1000)
    cib.call

    expect(cib.result[:chanchito]).to eq 2500
    expect(cib.result[:ica]).to eq 1100
    expect(cib.result[:retefuente]).to eq 16218
    expect(cib.result[:utility]).to eq 79182

  end

  it 'should calculate Ica, chanchito and retefuente with expensives and other incomes' do

    cib = CalculateTaxes.new(taxes: [@ica, @chanchito, @retefuente], invoice: {total: 100000}, incomes: 100000, expenses: 1000)
    cib.call

    expect(cib.result[:chanchito]).to eq 5000
    expect(cib.result[:ica]).to eq 2200
    expect(cib.result[:retefuente]).to eq 32606
    expect(cib.result[:utility]).to eq 159194

  end

end