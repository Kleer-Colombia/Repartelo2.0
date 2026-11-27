# Be sure to restart your server when you modify this file.

# CORS (Cross-Origin Resource Sharing): qué OTROS dominios pueden llamar a la
# API desde un navegador. La app (Vue) se sirve desde el mismo dominio que la
# API, así que no lo necesita.
#
# - Producción/staging: solo los orígenes de ALLOWED_ORIGINS (separados por
#   coma). Si no está definida, no se habilita ningún origen externo.
# - Desarrollo/test: si no está definida, cualquiera ('*'), como antes.
#
# Read more: https://github.com/cyu/rack-cors
allowed_origins = ENV.fetch('ALLOWED_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)
allowed_origins = ['*'] if allowed_origins.empty? && !Rails.env.production?

if allowed_origins.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*allowed_origins)

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
end
