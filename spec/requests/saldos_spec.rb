require 'rails_helper'

# Alta manual de saldos (pantalla Saldos > Agregar registro).
RSpec.describe 'Alta manual de saldos', type: :request do
  let(:admin) { User.create!(name: 'Admin', email: 'admin-saldos@example.com', password: 'una-clave-larga-123', admin: true) }
  let(:kleerer) { Kleerer.create!(name: 'KleererTest', option: Option.create!(name: 'opt-test', value: 1)) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id, exp: 1.hour.from_now.to_i)}",
      'CONTENT_TYPE' => 'application/json' }
  end

  before { Rack::Attack.reset! }

  def add(saldo)
    post '/api/v1/saldos/', params: { saldo: { kleerer_id: kleerer.id, date: '' }.merge(saldo) }.to_json, headers: headers
  end

  it 'con datos completos lo guarda' do
    expect { add(amount: -1500, concept: 'Pago', reference: 'https://kleer.la/x') }.to change(Saldo, :count).by(1)
    expect(response).to have_http_status(:ok)
  end

  it 'sin referencia ni concepto responde 422 con mensaje en español (antes 500) y no guarda nada' do
    expect { add(amount: 100, concept: '', reference: '') }.not_to change(Saldo, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    message = JSON.parse(response.body)['message']
    expect(message).to include('Concepto').and include('Referencia')
  end

  it 'con monto 0 responde 422' do
    expect { add(amount: 0, concept: 'x', reference: 'y') }.not_to change(Saldo, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['message']).to include('Monto')
  end

  it 'los saldos automáticos con monto 0 siguen permitidos' do
    expect(Saldo.new(kleerer: kleerer, amount: 0, concept: 'dist', reference: '/balance/1')).to be_valid
  end
end
