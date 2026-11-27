Rails.application.config.content_security_policy do |policy|
  policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035"
end if Rails.env.development?

# Producción (y staging, que corre con RAILS_ENV=production): segunda capa
# contra XSS. Aunque se colara HTML en la página, el navegador no ejecuta
# scripts inline ni de otros dominios, y no deja mandar datos (fetch, imágenes)
# a otros orígenes.
# - style-src 'unsafe-inline': Element UI y Vue ponen estilos inline; los
#   estilos no ejecutan código.
# - No hace falta 'unsafe-eval': Vue usa el build runtime (render functions,
#   sin compilar templates en el navegador) y webpack de producción no usa eval.
# Si algo deja de cargar, la consola del navegador muestra "Refused to ..."
# con la directiva que lo bloqueó.
Rails.application.config.content_security_policy do |policy|
  policy.default_src     :self
  policy.script_src      :self
  policy.style_src       :self, :unsafe_inline
  policy.img_src         :self, :data
  policy.font_src        :self, :data
  policy.connect_src     :self
  policy.object_src      :none
  policy.base_uri        :self
  policy.form_action     :self
  policy.frame_ancestors :self
end if Rails.env.production?
