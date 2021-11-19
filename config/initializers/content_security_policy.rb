Rails.application.config.content_security_policy do |policy|
  policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035"
end if Rails.env.development?