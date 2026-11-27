require 'rails_helper'

# Endurecimiento del login de la API (ver config/initializers/rack_attack.rb).
RSpec.describe 'Login de la API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let!(:user) { User.create!(name: 'Test', email: 'login-test@example.com', password: 'una-clave-larga-123') }

  before { Rack::Attack.reset! }
  after  { Rack::Attack.reset! }

  def login(username, password, ip: '203.0.113.10')
    post '/api/v1/login', params: { username: username, password: password }.to_json,
                          headers: headers.merge('REMOTE_ADDR' => ip)
  end

  it 'con credenciales correctas devuelve un token' do
    login('login-test@example.com', 'una-clave-larga-123')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).dig('response', 'token')).to be_present
  end

  it 'si falta un parámetro responde 400 (antes 500)' do
    post '/api/v1/login', params: { username: 'login-test@example.com' }.to_json, headers: headers
    expect(response).to have_http_status(:bad_request)
  end

  it 'si el hash guardado no es bcrypt responde 401 (antes 500)' do
    user.update_column(:password_digest, 'no-es-un-hash-bcrypt')
    login('login-test@example.com', 'no-es-un-hash-bcrypt')
    expect(response).to have_http_status(:unauthorized)
  end

  it 'corta con 429 al superar 10 intentos por minuto desde la misma IP' do
    10.times { |i| login("nadie#{i}@example.com", 'x') }
    expect(response).to have_http_status(:unauthorized)
    login('otro@example.com', 'x')
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'corta con 429 al superar 10 intentos para el mismo usuario desde distintas IPs' do
    10.times { |i| login('login-test@example.com', 'mala', ip: "198.51.100.#{i + 1}") }
    login('login-test@example.com', 'una-clave-larga-123', ip: '198.51.100.200')
    expect(response).to have_http_status(:too_many_requests)
  end
end
