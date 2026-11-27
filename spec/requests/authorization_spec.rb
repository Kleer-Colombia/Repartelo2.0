require 'rails_helper'

# Autorización de la API: leer cualquiera logueado; modificar solo admin.
RSpec.describe 'Autorización de la API', type: :request do
  let(:admin)  { User.create!(name: 'Admin', email: 'admin-authz@example.com', password: 'una-clave-larga-123', admin: true) }
  let(:reader) { User.create!(name: 'Lector', email: 'lector-authz@example.com', password: 'una-clave-larga-123') }

  before { Rack::Attack.reset! }

  def auth_for(user)
    { 'Authorization' => "Bearer #{JwtService.encode(user_id: user.id, exp: 1.hour.from_now.to_i)}",
      'CONTENT_TYPE' => 'application/json' }
  end

  it 'un usuario no admin puede leer' do
    get '/api/v1/balance', headers: auth_for(reader)
    expect(response).to have_http_status(:ok)
  end

  it 'un usuario no admin no puede modificar (403 con mensaje)' do
    post '/api/v1/balance/new', params: { balance: { client: 'x' } }.to_json, headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)['message']).to be_present
    delete '/api/v1/balance/1', headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)
  end

  it 'un admin pasa la autorización al modificar' do
    post '/api/v1/saldos/', params: {}.to_json, headers: auth_for(admin)
    expect(response).not_to have_http_status(:forbidden)
  end

  it 'sin token sigue siendo 401 (no 403)' do
    post '/api/v1/balance/new', params: {}.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'el login no exige admin' do
    post '/api/v1/login', params: { username: reader.email, password: 'una-clave-larga-123' }.to_json,
                          headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
  end

  it 'summary de coaching: leer sí, actualizar porcentajes solo admin' do
    post '/api/v1/balance/999999/coachingSessions/summary',
         params: { updatePercentage: false }.to_json, headers: auth_for(reader)
    expect(response).not_to have_http_status(:forbidden)
    post '/api/v1/balance/999999/coachingSessions/summary',
         params: { updatePercentage: true }.to_json, headers: auth_for(reader)
    expect(response).to have_http_status(:forbidden)
  end
end
