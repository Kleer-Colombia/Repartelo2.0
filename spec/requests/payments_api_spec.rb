require 'rails_helper'
require 'support/sales_invoice_helpers'

# API de Pagos y facturas: cualquiera logueado lee; registrar pagos y
# forzar la lectura del Drive, solo admin.
RSpec.describe 'API de Pagos', type: :request do
  let(:admin)  { User.create!(name: 'Admin', email: 'admin-pagos@example.com', password: 'una-clave-larga-123', admin: true) }
  let(:reader) { User.create!(name: 'Lector', email: 'lector-pagos@example.com', password: 'una-clave-larga-123') }

  before { Rack::Attack.reset! }

  def auth_for(user)
    { 'Authorization' => "Bearer #{JwtService.encode(user_id: user.id, exp: 1.hour.from_now.to_i)}",
      'CONTENT_TYPE' => 'application/json' }
  end

  def body
    JSON.parse(response.body)['response']
  end

  it 'lista pendientes y facturas disponibles para un lector' do
    create_sales_invoice('API1')

    get '/api/v1/payments', params: { status: 'pending' }, headers: auth_for(reader)
    expect(response).to have_http_status(:ok)
    expect(body['invoices'].map { |i| i['number'] }).to eq ['API1']

    get '/api/v1/invoice', headers: auth_for(reader)
    expect(response).to have_http_status(:ok)
    expect(body['invoices'].first).to include('number' => 'API1', 'paid' => false)
  end

  it 'solo un admin registra o borra pagos' do
    create_sales_invoice('API1')
    payment = { payment: { paidOn: '2026-11-20', amount: 1000, retefuente: 10 } }.to_json

    post '/api/v1/payments/API1', params: payment, headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)

    post '/api/v1/payments/API1', params: payment, headers: auth_for(admin)
    expect(response).to have_http_status(:ok)
    expect(SalesInvoice.find_by(number: 'API1').payment.retefuente).to eq 10

    delete '/api/v1/payments/API1', headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)
    delete '/api/v1/payments/API1', headers: auth_for(admin)
    expect(response).to have_http_status(:ok)
  end

  it 'forzar la lectura del Drive es solo para admin' do
    post '/api/v1/invoice/sync', headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)
  end
end
