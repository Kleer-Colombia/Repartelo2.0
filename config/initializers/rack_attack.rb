# Límite de intentos de login contra fuerza bruta, en la API (/api/v1/login)
# y en ActiveAdmin (/admin/login). Si se supera, responde 429.
#
# El contador vive en memoria del proceso: hay un solo contenedor web con un
# solo proceso de Puma (sin `workers`), así que alcanza y no necesita Redis.
# Se reinicia con cada deploy, lo cual está bien para este uso.
#
# La IP es la del cliente real: kamal-proxy manda X-Forwarded-For y Rack
# saltea los proxies de redes privadas (la red de Docker).
class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  LOGIN_PATHS = %w[/api/v1/login /admin/login].freeze

  def self.login_request?(req)
    req.post? && LOGIN_PATHS.include?(req.path)
  end

  # Usuario que intenta loguearse. La app manda JSON (axios), que Rack no
  # parsea en req.params; ActiveAdmin manda un form.
  def self.login_identifier(req)
    return (req.params["admin_user"] || {})["email"] if req.path == "/admin/login"
    return req.params["username"] unless req.media_type == "application/json"

    body = req.body.read(10_000)
    req.body.rewind
    JSON.parse(body.to_s)["username"]
  rescue JSON::ParserError, TypeError, NoMethodError
    nil
  end

  # Por IP: 10 intentos por minuto y 30 por hora.
  throttle("login/ip/minute", limit: 10, period: 60) do |req|
    req.ip if login_request?(req)
  end
  throttle("login/ip/hour", limit: 30, period: 3600) do |req|
    req.ip if login_request?(req)
  end

  # Por usuario (aunque el atacante rote IPs): 10 intentos por hora.
  throttle("login/user/hour", limit: 10, period: 3600) do |req|
    login_identifier(req).to_s.strip.downcase.presence if login_request?(req)
  end

  self.throttled_response_retry_after_header = true
  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" },
     [{ message: "Demasiados intentos. Probá de nuevo más tarde." }.to_json]]
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn "[rack-attack] #{req.env['rack.attack.matched']} ip=#{req.ip} path=#{req.path}"
end
