# Repártelo — instrucciones para Claude

Rails 5.2 + Vue 2 (Webpacker). Hosting: Hetzner con Kamal (migrando desde
Heroku). Toda la operación está en `docs/MIGRACION_HETZNER.md`: leerlo
antes de tocar infraestructura o deploy, y mantenerlo actualizado.

## Regla de deploy: staging SIEMPRE antes que producción

Todo pasaje de ambientes sigue este orden, sin excepciones (tampoco para
"cambios chicos", primeros deploys ni urgencias sin acuerdo explícito):

1. **Staging** (`https://qa.r.kleer.la`): `kamal deploy -d staging`
   (y `kamal app exec -d staging 'bin/rails db:migrate'` si hay migraciones).
2. **Pruebas sobre staging**, con esa versión exacta: `/up`, home, login,
   pantallas clave, `kamal app logs -d staging` sin errores nuevos.
3. **Reportar** el resultado y esperar el OK.
4. **Producción** (`https://r.kleer.la`) con la **misma imagen** que pasó
   las pruebas, sin rebuildear:
   `kamal deploy --skip-push --version <versión que corre en staging>`
   (la versión sale de `kamal app version -d staging`).

Si staging falla, producción no se toca. El hook `.kamal/hooks/pre-deploy`
bloquea un deploy a producción cuya versión no esté corriendo en staging.

## Otras reglas del proyecto

- Secretos reales solo en `.env.kamal` (no trackeado). Nunca mostrarlos ni
  pegarlos en el chat, commits o docs.
- No commitear sin que lo pida el usuario.
- Datos de producción (dumps) fuera del repo y fuera de Dropbox.
