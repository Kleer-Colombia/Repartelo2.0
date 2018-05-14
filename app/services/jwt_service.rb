class JwtService

    @@logger = Logger.new(STDOUT)

    def self.encode(payload)
      JWT.encode(payload, Rails.application.secrets.secret_key_base, 'HS256')
    end

    def self.decode(token)
      body, = JWT.decode(token, Rails.application.secrets.secret_key_base,
                         true, algorithm: 'HS256')
      HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature => e
      @@logger.debug "decode error: #{e}"
      nil
    rescue JWT::InvalidIssuerError => e
      @@logger.debug "decode error: #{e}"
      nil
    rescue JWT::InvalidIatError => e
      @@logger.debug "decode error: #{e}"
      nil
    rescue JWT::DecodeError => e
      @@logger.debug "decode error: #{e}"
      nil
    end
end