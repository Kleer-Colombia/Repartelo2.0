# Repártelo — instrucciones para Claude

Rails 5.2 + Vue 2 (Webpacker). Hosting: **Hetzner con Kamal, y nada más**.
Toda la operación está en `docs/MIGRACION_HETZNER.md`: leerlo antes de tocar
infraestructura o deploy, y mantenerlo actualizado.

**Heroku NO se usa más (desde 2026-11-27).** Los ambientes reales son
`https://r.kleer.la` (producción) y `https://qa.r.kleer.la` (staging), en
Hetzner. No desplegar, configurar, migrar ni probar nada en Heroku
(`repartelo2`, `repartelo2-staging`); sus apps quedan solo hasta que se den
de baja (decisión del usuario).

## Regla de deploy: PR → main → staging → producción

Todo cambio sigue este orden, sin excepciones (tampoco para "cambios
chicos", hotfixes ni urgencias sin acuerdo explícito del usuario):

1. **PR a `main`** desde una rama propia, con tests. **CI en verde** y
   revisión (el usuario, Leo, Santi o un `/code-review`).
2. **Merge a `main`** con el OK del usuario. Nunca se despliega una rama
   sin mergear: staging y producción corren siempre un commit de `main`.
3. **Staging** (`https://qa.r.kleer.la`), desde `main` actualizado
   (`git pull` / worktree en `origin/main`): `kamal deploy -d staging`
   (y `kamal app exec -d staging 'bin/rails db:migrate'` si hay migraciones,
   o mejor, con la imagen nueva antes del deploy:
   `kamal app exec -d staging --version <v> 'bin/rails db:migrate'`).
4. **Pruebas sobre staging**, con esa versión exacta: `/up`, home, login,
   pantallas clave, `kamal app logs -d staging` sin errores nuevos.
5. **Reportar** el resultado y esperar el OK.
6. **Producción** (`https://r.kleer.la`) con la **misma imagen** que pasó
   las pruebas, sin rebuildear:
   `kamal deploy --skip-push --version <versión que corre en staging>`
   (la versión sale de `kamal app version -d staging`).

Si staging falla, producción no se toca, y en `main` se revierte el merge
(`git revert -m 1 <merge>` en un PR) o se corrige con otro PR.

El hook `.kamal/hooks/pre-deploy` lo fuerza: bloquea un deploy a staging
cuya versión no esté en `origin/main` (o tenga cambios sin commitear) y un
deploy a producción cuya versión no esté corriendo en staging. Overrides de
emergencia (solo con OK explícito del usuario): `KAMAL_ALLOW_UNMERGED=1`
(staging) y `KAMAL_ALLOW_PROD_WITHOUT_STAGING=1` (producción).

## Trabajo en paralelo (varias sesiones a la vez)

Es habitual que haya varias sesiones de Claude trabajando al mismo tiempo en
este repo. Reglas:

1. **Un worktree por sesión.** Cada sesión trabaja en su propio worktree
   (`.claude/worktrees/<nombre>`) y en su propia rama. Nadie trabaja en la
   carpeta principal del repo: ahí puede haber otra sesión y los commits caen
   en la rama equivocada. Antes de commitear, confirmar con
   `git branch --show-current` que la rama es la propia y revisar
   `git diff --cached --stat`: un commit se lleva TODO lo que esté en el
   índice, también lo que preparó otra sesión (pasó: incidencia 13).
2. **Staging es uno solo: un cambio por vez.** Hay un turno: lo que se
   mergeó a `main` pasa staging → pruebas → OK del usuario → producción, y
   recién entonces se despliega lo próximo. Antes de desplegar a staging,
   avisar a las otras sesiones (`ListAgents` / `SendMessage`) y confirmar
   que nadie está probando ahí. Al terminar un pasaje a producción, avisar
   la versión.
3. **Cada deploy incluye lo que ya está en producción.** Se cumple solo
   porque siempre se despliega `main` (que contiene todo lo anterior). Por
   eso mismo, no mergear a `main` algo nuevo mientras otro cambio está a
   mitad de camino en staging sin avisar: el próximo deploy lo llevaría.
4. **PRs chicos y rebaseados sobre `origin/main`** antes de pedir el merge.
5. **Recursos locales compartidos:** el contenedor de desarrollo
   (`at_repartelo-repartelo-1`) monta solo la carpeta principal, y la base
   de test es una sola. Para tests desde un worktree, usar un contenedor
   aparte con el worktree montado y una base propia (`DATABASE_URL=…/repartelo_test_<rama>`).
   No reiniciar ni modificar contenedores de otra sesión.
6. **Migraciones:** avisar a las otras sesiones al crear una, porque
   staging y producción las reciben en el orden en que llegan los deploys.

## Estado y continuidad entre sesiones

(Tomado del método de HomeSuite/tas-king, adaptado.)

- **`docs/STATUS.md`** registra solo **publicaciones y verificaciones**: qué
  versión (SHA de `main`) corre en cada ambiente, migraciones y tareas
  corridas, smoke, quién dio el OK. Lo actualiza quien publica, en la misma
  sesión (en un PR chico de docs). Lo que está en `main` sin publicar no se
  anota: se calcula con `git diff --stat <SHA publicado> origin/main`.
- **El estado de un PR no se escribe en ningún doc** ("en PR", "pendiente
  staging", "sin mergear"): vive en GitHub y en el doc se vuelve falso al
  mergear.
- **`docs/HANDOFF.md`** guarda solo lo que no vive en un PR (una prueba o
  tarea pendiente, una decisión que espera al usuario, algo para
  Administración), en bloques **Qué / Falta / Cuidado / Fecha**. Se actualiza
  cuando el estado cambia, no al final; lo terminado sale del handoff.
- **Al retomar:** leer STATUS y HANDOFF, verificar contra la realidad
  (`gh pr list --state all`, `kamal app version [-d staging]`,
  `git branch -r --no-merged origin/main`) antes de actuar, y decirle al
  usuario qué se encontró, sobre todo si no coincide.
- **Merge, staging y producción son tres órdenes distintas del usuario**;
  una aprobación no se extiende al paso siguiente salvo que lo diga ("hagamos
  merge y staging").
- **Smoke después de publicar:** `/up`, home, logs sin errores nuevos, la
  versión con `kamal app version`, y el recorrido afectado; si toca pantallas
  con login, lo prueba una persona con su cuenta (Claude no usa credenciales
  reales).

## Criterios técnicos aprendidos

- **Validaciones sobre datos existentes:** antes de imponer una regla (ej.
  "la distribución tiene que coincidir con la utilidad"), medirla contra los
  datos reales de staging. La regla ingenua bloqueaba todos los balances con
  clearings; la correcta salió de verificarla en 297 balances.
- **Migraciones incompatibles con el código anterior** (renombrar o borrar
  columnas): preferir expandir → migrar el código → retirar en deploys
  separados. Si se hace en uno solo, correr `db:migrate` con la imagen nueva
  justo antes del deploy y avisar la ventana de errores.
- **Antes de commitear:** agregar por ruta y revisar `git diff --cached --stat`
  (incidencia 13).

## Herramientas locales

- **Kamal:** `script/kamal …` (o `kamal …`, que en la máquina de Pablo es
  `~/.local/bin/kamal` y llama a ese script). Corre Kamal en Docker y
  funciona desde un worktree. Para desplegar, worktree en `origin/main`:
  `git switch --detach origin/main`.
- **Tests desde un worktree** (contenedor aparte, base propia, gemas en un
  volumen; la imagen de desarrollo está vieja, ver incidencia 14):
  ```bash
  docker run --rm --network at_repartelo_default -v "$PWD:/app" -w /app \
    --env-file .env -e RAILS_ENV=test -e BUNDLE_PATH=/bundle -e DISABLE_SPRING=1 \
    -e POSTGRES_USERNAME=postgres -e PG_HOST=postgres \
    -v repartelo_bundle:/bundle at_repartelo-repartelo bash -c \
    'export DATABASE_URL="${DATABASE_URL%/*}/repartelo_test_<rama>"; bundle install --quiet &&
     bundle exec rails db:create db:schema:load && bundle exec rspec'
  ```
- **Copiar producción a staging:** ver `docs/MIGRACION_HETZNER.md`, sección 6.

## Otras reglas del proyecto

- Secretos reales solo en `.env.kamal` (no trackeado). Nunca mostrarlos ni
  pegarlos en el chat, commits o docs.
- No commitear sin que lo pida el usuario.
- Datos de producción (dumps) fuera del repo y fuera de Dropbox.
