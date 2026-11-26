# Migración Repártelo: Heroku → Hetzner

Guía y bitácora de la migración de Repártelo desde Heroku a un server propio
en Hetzner. El objetivo es **dejar de pagar Heroku**: tanto producción
(`repartelo2`) como staging (`repartelo2-staging`) pasan a Hetzner.

Última actualización: **2026-11-25**.

| Ambiente | URL |
|---|---|
| Producción | https://r.kleer.la |
| Staging (QA) | https://qa.r.kleer.la |

---

## Estado actual (resumen)

| Etapa | Estado |
|---|---|
| 1. Entorno de desarrollo local | ✅ Funcionando |
| 2. Server en Hetzner (Docker, firewall, Postgres, backups) | ✅ Listo |
| 3. Datos de producción cargados en Hetzner | ✅ Backup de Heroku del 2026-11-24 (habrá que refrescarlo antes del corte) |
| 4. Staging en Hetzner (base de datos) | ✅ Copia de producción cargada |
| 5. Deploy de la app (prod y staging) | ✅ Ambos arriba desde 2026-11-25, con la misma imagen. Falta prueba funcional con usuarios (login, pantallas) |
| 6. Dominios + HTTPS | ✅ `r.kleer.la` y `qa.r.kleer.la`, certificados Let's Encrypt (vencen 2027-02-23, se renuevan solos) |
| 6b. Regla staging → producción | ✅ En `CLAUDE.md` y forzada por el hook `.kamal/hooks/pre-deploy` (sección 4) |
| 7. Corte: refrescar datos, avisar a usuarios, apagar Heroku | ⬜ Pendiente |

### Pendientes que bloquean

Ninguno al 2026-11-25. (El bloqueo de GHCR se resolvió: ver incidencia 8.)

### Pendientes que no bloquean

- **Prueba funcional** de staging (`https://qa.r.kleer.la`) con un usuario
  real: login, pantallas principales, cálculos. Hasta ahora se verificó
  infraestructura (HTTPS, `/up`, home, conexión a la base correcta, logs).
- **CORS** (`ALLOWED_ORIGINS`): en Heroku no está definida, así que la app
  permite cualquier origen (`*`). En Hetzner se dejó igual (la variable no
  se pasa). Si se quiere restringir: agregarla en `env.clear` de cada
  `deploy*.yml` (no es secreta), confirmando antes que nada externo
  consuma la API.
- **SMTP / ActionMailer**: `config/deploy.yml` lista `SMTP_*` y
  `ACTION_MAILER_*`, pero ningún archivo de `config/` ni `app/` las lee
  (vienen de la plantilla genérica de `.env`). Confirmar si la app manda
  mails en producción y cómo, antes de decidir si se quedan.
- **Backups fuera del server**: hoy quedan en el mismo disco que la base.
  Evaluar Hetzner Storage Box o la opción *Backups* del server (+20%).
- **Migraciones en deploy**: Heroku corría `db:migrate` solo (fase
  `release` del `Procfile`); Kamal no. Hoy hay que correrlas a mano
  después de cada deploy que traiga migraciones (o agregar un hook
  `.kamal/hooks/pre-deploy` más adelante).
- **Seguridad**: `.env` está trackeado en git (ya **no** entra en la
  imagen: está en `.dockerignore`); sacarlo del tracking y rotar lo que haya
  pasado por ahí. `db/repartelo20180513.backup` sigue suelto en el repo.
- **Stack EOL**: Ruby 2.7.7, Rails 5.2, Node 14 y Debian bullseye están
  fuera de soporte. No bloquea la migración, pero es la deuda técnica más
  grande.

---

## 1. Qué stack tiene Repártelo

- **Backend**: Ruby on Rails 5.2.3 sobre Ruby 2.7.7 (ambos EOL)
- **Frontend**: Vue.js 2 embebido vía Webpacker 5 (no es SPA separada)
- **Server**: Puma 3.12; Node 14.17.6 (EOL) + Yarn 1.x
- **Tests**: RSpec + Cucumber/Capybara/Selenium
- **Base de datos**: PostgreSQL. 44 migraciones (la última,
  `20230510170130`). Producción lee `DATABASE_URL`.
- **Variables que lee el código**: `DATABASE_URL`, `SECRET_KEY_BASE`,
  `ALEGRA_EMAIL`, `ALEGRA_TOKEN`, `ALLOWED_ORIGINS`, `RAILS_LOG_TO_STDOUT`,
  `RAILS_MAX_THREADS`, `WEB_CONCURRENCY`, `PORT` (más las de
  `database.yml` en dev/test).

### Heroku hoy (lo que se va a reemplazar)

| | Producción | Staging |
|---|---|---|
| App | `repartelo2` | `repartelo2-staging` (pipeline `repartelo2-stage`) |
| URL | `repartelo2.herokuapp.com` | `repartelo2-staging-3050fbcd8551.herokuapp.com` |
| Dominio propio | ninguno | ninguno |
| Dyno | 1 × Basic | — |
| Postgres | `essential-1`, **PG 17.10**, 15,2 MB, 25 tablas | — |
| Deploy | contenedor (`heroku.yml` + `Dockerfile`), manual | auto-deploy de la rama `dockerizing-prod` |

Como no hay dominio propio, **al apagar Heroku cambia la URL** para los
usuarios: hay que avisarles de `r.kleer.la`.

Backups en Heroku: el último *programado* es de junio 2024; después solo
hay manuales. Se decidió no reprogramarlos en Heroku y resolverlo en
Hetzner (ver sección Backups).

---

## 2. Entorno de desarrollo local

### Prerrequisitos

- Docker Engine + Compose plugin (instalación oficial, no `docker.io` de
  Ubuntu):

  ```bash
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker $USER   # cerrar sesión y volver a entrar después
  ```

- Si el disco donde vive `/var/lib/docker` es chico, mover el `data-root`
  de Docker a una partición con más espacio (incidencia 2).

### Archivos locales (no trackeados en git a propósito)

- **`Dockerfile.dev`**: igual al `Dockerfile` de producción, pero instala
  también las gemas de development/test (RSpec/Cucumber/Capybara).
- **`docker-compose.override.yml`**: hace que `repartelo` y `webpacker`
  usen `Dockerfile.dev` y agrega `PG_HOST` y `POSTGRES_USERNAME`
  (incidencia 3). Compose lo mezcla solo con `docker-compose.yml`.

En una máquina nueva hay que **recrear estos dos archivos**:

`Dockerfile.dev`:
```dockerfile
# Dockerfile de desarrollo local (no usado en producción/Heroku).
# A diferencia del Dockerfile raíz, instala TODOS los grupos de gemas
# (development/test incluidos) para poder correr rspec/cucumber localmente.
FROM ruby:2.7.7
WORKDIR /app

# NOTA: ruby:2.7.7 corre sobre Debian bullseye, que ya pasó a
# archive.debian.org (deb.debian.org devuelve 404). Mismo arreglo que el
# Dockerfile de producción (ver docs/MIGRACION_HETZNER.md).
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && apt-get update -qq -o Acquire::Check-Valid-Until=false \
 && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  postgresql-client \
  dos2unix

RUN apt-get install -y nodejs npm
RUN npm install -g n && n 14.17.6
RUN npm install -g yarn@1.22.19
RUN gem install bundler:2.3.25

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . ./

CMD ["bash", "-c", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
```

`docker-compose.override.yml`:
```yaml
services:
  repartelo:
    build:
      dockerfile: Dockerfile.dev
    environment:
      POSTGRES_USERNAME: postgres
      PG_HOST: postgres
  webpacker:
    build:
      dockerfile: Dockerfile.dev
    environment:
      POSTGRES_USERNAME: postgres
      PG_HOST: postgres
```

### Levantar desde cero

```bash
docker compose build repartelo
docker compose up -d postgres webpacker repartelo
docker compose exec -T repartelo yarn install      # el bind mount tapa node_modules (incidencia 4)
docker compose up -d webpacker
docker compose exec -T repartelo bundle exec rails db:create db:migrate

curl -I http://localhost:4000/                      # 200
curl http://localhost:4000/up                       # OK
docker compose exec -T repartelo bundle exec rspec
```

El Postgres local sigue en **13** (`docker-compose.yml`): su volumen tiene
datos de esa versión. Producción y staging en Hetzner usan **17**.

---

## 3. Infraestructura en Hetzner

### Server

| | |
|---|---|
| IP | `2.29.193.202` |
| Tipo | Hetzner Cloud CX (amd64), 2 vCPU, 4 GB RAM, 38 GB disco |
| Sistema | Ubuntu 26.04.1 LTS, zona horaria UTC |
| Acceso | SSH como `root`, solo con clave (claves de Pablo y Leo cargadas al crearlo) |
| Firewall | `ufw` activo: entrada solo 22, 80 y 443 |
| Docker | instalado por `kamal setup` (get.docker.com) |

### Contenedores

| Contenedor | Qué es | Puerto | Datos |
|---|---|---|---|
| `repartelo-postgres` | Postgres 17 de **producción**, base `repartelo_production` | `127.0.0.1:5432` | `/root/repartelo-postgres/data` |
| `repartelo-staging-postgres` | Postgres 17 de **staging**, base `repartelo_staging` | `127.0.0.1:5433` | `/root/repartelo-staging-postgres/data` |
| `repartelo-web-<versión>` | app de **producción** (`https://r.kleer.la`) | — (detrás de kamal-proxy) | — |
| `repartelo-web-staging-<versión>` | app de **staging** (`https://qa.r.kleer.la`) | — (detrás de kamal-proxy) | — |
| `kamal-proxy` | reverse proxy + TLS para los dos dominios | 80, 443 | certificados |

Los Postgres escuchan solo en loopback: no son accesibles desde internet.
Todos los contenedores están en la red Docker `kamal`; la app llega a su
base por nombre (`repartelo-postgres` / `repartelo-staging-postgres`).
Ambos tienen `--restart unless-stopped`.

---

## 4. Cómo se opera: Kamal

[Kamal](https://kamal-deploy.org) buildea la imagen, la sube a GHCR
(`ghcr.io/kleer-colombia/repartelo`) y la despliega por SSH.

### Kamal sin instalar Ruby

La máquina del operador no necesita Ruby: Kamal corre desde su imagen
oficial de Docker. Agregar esta función al `~/.bashrc`:

```bash
kamal() {
  docker run --rm -it \
    -v "$PWD:/workdir" \
    -v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$HOME/.ssh/known_hosts:/root/.ssh/known_hosts:ro" \
    --env-file .env.kamal \
    ghcr.io/basecamp/kamal:latest "$@"
}
```

Requisitos: estar en la carpeta del proyecto, tener la clave SSH cargada
en el agente (`ssh-add -l`) y el archivo `.env.kamal` completo.

### Archivos de configuración

| Archivo | En git | Qué tiene |
|---|---|---|
| `config/deploy.yml` | sí | config de **producción** |
| `config/deploy.staging.yml` | sí | lo que cambia para **staging** (se mezcla encima del anterior con `-d staging`) |
| `.kamal/secrets` | sí | mapeo de secretos de producción, **sin valores** (cada línea lee una variable de entorno) |
| `.kamal/secrets.staging` | sí | ídem para staging (usa las variables `STAGING_*`) |
| `.env.kamal` | **no** (`.gitignore`, permisos 600) | **los valores reales** de todos los secretos |
| `.dockerignore` | sí | excluye `.env`, `.env.*` y `.kamal/secrets*` de la imagen |
| `.kamal/hooks/pre-deploy` | sí | bloquea deploys a producción de versiones que no corren en staging |
| `CLAUDE.md` | sí | reglas para Claude (incluye la de staging → producción) |

### `.env.kamal` (secretos reales)

Vive solo en la máquina del operador. Formato `CLAVE=valor`, **sin
comillas** (lo lee `docker --env-file`, que no las quita). Contiene:

- `KAMAL_REGISTRY_PASSWORD`: token de GitHub con scope `write:packages`.
  Se carga sin mostrarlo con:
  `sed -i "s|^KAMAL_REGISTRY_PASSWORD=.*|KAMAL_REGISTRY_PASSWORD=$(gh auth token)|" .env.kamal`
  (antes: `gh auth refresh -h github.com -s write:packages`).
- `SECRET_KEY_BASE`, `POSTGRES_PASSWORD`: de producción, generados el
  2026-11-24 con `openssl rand`. **Ojo**: `SECRET_KEY_BASE` es distinto del
  de Heroku; en el corte, usar el de Heroku para no invalidar sesiones
  abiertas.
- `STAGING_SECRET_KEY_BASE`, `STAGING_POSTGRES_PASSWORD`: de staging,
  distintos de producción.
- `ALEGRA_EMAIL`, `ALEGRA_TOKEN`: copiados de Heroku (`repartelo2`) el
  2026-11-25; los usan producción y staging (en Heroku también son las
  mismas en ambas apps). La integración solo **lee** facturas de Alegra
  (`GET /invoices`), así que staging no puede modificar nada allá.
- `SMTP_*`, `ACTION_MAILER_*`: vacías (ver Pendientes).

**Nunca** pegar estos valores en chats, tickets ni commits. Si se pierde
`.env.kamal`, las contraseñas de Postgres se pueden recuperar del server
(`/root/.kamal/apps/repartelo*/env/`), pero conviene guardar una copia en
un gestor de contraseñas.

### Regla: staging SIEMPRE antes que producción

Todo pasaje de ambientes sigue este orden:

```bash
# 1. Staging: buildea, pushea y despliega
kamal deploy -d staging
kamal app exec -d staging 'bin/rails db:migrate'   # si hay migraciones

# 2. Pruebas sobre https://qa.r.kleer.la (esa versión exacta):
#    /up, home, login, pantallas clave, `kamal app logs -d staging` sin errores nuevos.

# 3. OK explícito de quien es responsable del cambio.

# 4. Producción: la MISMA imagen que se probó, sin rebuildear
kamal app version -d staging                        # anotar la versión
kamal deploy --skip-push --version <versión>
kamal app exec 'bin/rails db:migrate'               # si hay migraciones
```

**Por qué funciona "la misma imagen"**: staging y producción comparten el
`service` (`repartelo`); Kamal etiqueta cada imagen con su service y se
niega a correrla en otro (incidencia 10). El ambiente se distingue por el
*destino*: los contenedores de staging se llaman `repartelo-web-staging-…`.

**Hook `.kamal/hooks/pre-deploy`** (lo corre Kamal antes de cada deploy):

| Caso | Resultado |
|---|---|
| Deploy a staging | pasa siempre |
| Deploy a producción de una versión que **corre en staging** | ✅ pasa |
| Deploy a producción de una versión que **no** corre en staging | ❌ se cancela, con instrucciones |
| `kamal rollback` en producción | pasa (vuelve a una versión que ya estuvo en prod) |
| Emergencia acordada | pasa con `-e KAMAL_ALLOW_PROD_WITHOUT_STAGING=1` en el `docker run` (queda impreso en la salida) |

Probado en los cinco casos el 2026-11-25. Consecuencia práctica: un
`kamal deploy` "pelado" a producción (que rebuildea) siempre se va a
bloquear, porque la versión nueva no puede estar en staging. Es a propósito.

### Comandos habituales

```bash
kamal app logs -f                              # (-d staging para staging)
kamal app exec -i 'bin/rails console'
kamal app version                              # versión corriendo
kamal rollback <versión>                       # volver atrás en producción

# Bases de datos
kamal accessory details postgres               # (-d staging para staging)
ssh root@2.29.193.202 'docker exec -it repartelo-postgres psql -U repartelo repartelo_production'
ssh root@2.29.193.202 'docker exec -it repartelo-staging-postgres psql -U repartelo repartelo_staging'
```

`kamal app ...` sin `-d` actúa sobre producción. Revisar siempre el `-d`.

### Build desde git

Kamal buildea desde el **último commit** (no desde los archivos locales):
lo que no está commiteado no entra en la imagen, y la versión de cada
imagen es el SHA del commit. Hasta el 2026-11-25 se usó temporalmente
`builder.context: .` para probar sin commitear (versiones
`…_uncommitted_…`); se sacó al commitear.

---

## 5. Dominios y HTTPS

DNS creado el 2026-11-25 por los administradores de `kleer.la`:

| Ambiente | Subdominio | Registro DNS | Config |
|---|---|---|---|
| Producción | `r.kleer.la` | A → `2.29.193.202` | `config/deploy.yml` → `proxy.host` |
| Staging (QA) | `qa.r.kleer.la` | A → `2.29.193.202` | `config/deploy.staging.yml` → `proxy.host` |

Ambos con `ssl: true`: `kamal-proxy` pide el certificado de Let's Encrypt
en el primer deploy de cada ambiente, lo renueva solo y redirige HTTP a
HTTPS. Por eso el firewall tiene que dejar abierto el 80, además del 443.

El `host` es lo que le permite a `kamal-proxy` servir dos apps en la misma
IP: enruta según el dominio pedido. Consecuencia: la app **no responde por
IP** (`http://2.29.193.202`), solo por su dominio.

En Kamal el ambiente se sigue llamando `staging` (`-d staging`); "QA" es
solo el nombre del subdominio.

## 6. Datos y backups

### Carga inicial (2026-11-24)

1. En Heroku: backup manual `b2259` de `repartelo2` (`heroku pg:backups:capture`).
2. Descargado a la máquina del operador, **fuera de Dropbox y de git**:
   `~/backups/repartelo/repartelo2-b2259-2026-11-24.dump` (permisos 600;
   SHA-256 `70fa013f8bc6acb39aa7cc6ab13a3df69bac0ada1de5df2c4d511647ee2e71e0`).
3. Verificado restaurándolo en un Postgres 17 descartable: 25 tablas,
   44 migraciones, coincide con `db/schema.rb`.
4. Subido al server, restaurado en `repartelo_production` (sin errores,
   mismas filas por tabla), y borrada la copia subida.
5. Staging: copia directa de producción dentro del server
   (`pg_dump | pg_restore`, sin sacar datos de la máquina). Verificado
   idéntico: 25 tablas, 25.799 filas.

⚠️ **Staging tiene datos reales de producción** (facturas, saldos,
usuarios). Tratarlo con el mismo cuidado que producción.

### Refrescar los datos antes del corte

Mientras Heroku siga en uso, la base de Hetzner se desactualiza. Antes del
corte (con Heroku en modo mantenimiento para que nadie escriba):

```bash
heroku maintenance:on -a repartelo2
heroku pg:backups:capture -a repartelo2
heroku pg:backups:download -a repartelo2 -o ~/backups/repartelo/corte.dump
scp ~/backups/repartelo/corte.dump root@2.29.193.202:/root/corte.dump
ssh root@2.29.193.202 'docker exec -i repartelo-postgres pg_restore -U repartelo -d repartelo_production --clean --if-exists --no-owner --no-acl < /root/corte.dump && rm /root/corte.dump'
```

### Backups automáticos en el server

- Script: `script/backup_postgres.sh` (en el repo), instalado en el server
  como `/usr/local/bin/repartelo-backup`.
- Cron: `/etc/cron.d/repartelo-backup`, todos los días a las **07:00 UTC
  (02:00 Bogotá)**. Log: `/var/log/repartelo-backup.log`.
- Qué hace: `pg_dump` en formato custom de `repartelo_production`, lo
  verifica con `pg_restore --list` antes de darlo por bueno (un dump vacío
  o roto nunca desplaza a uno bueno) y **deja los últimos 5**.
- Dónde: `/var/backups/repartelo/` (solo root).
- Solo cubre **producción**; staging no tiene backups (se puede volver a
  copiar de producción).

Restaurar un backup:
```bash
ssh root@2.29.193.202
docker exec -i repartelo-postgres pg_restore -U repartelo -d repartelo_production \
  --clean --if-exists --no-owner < /var/backups/repartelo/ARCHIVO.dump
```

Correr un backup a mano: `ssh root@2.29.193.202 /usr/local/bin/repartelo-backup`.

---

## 7. Incidencias y cómo se resolvieron

### 1. `ruby:2.7.7` (Debian bullseye) ya no instala paquetes

Primero falló por firmas (`At least one invalid signature was
encountered`) y se parchó con flags inseguros de apt. Después, al
buildear sin caché (primer `kamal setup`), `deb.debian.org` devolvió
**404** para los paquetes de bullseye: la versión pasó a
`archive.debian.org`.

**Solución** (en `Dockerfile` y `Dockerfile.dev`): reapuntar las fuentes
al archivo. Ahí las firmas validan bien, así que **se sacaron los flags
inseguros** (`--allow-unauthenticated`, etc.):
```dockerfile
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && apt-get update -qq -o Acquire::Check-Valid-Until=false \
 && apt-get install -y build-essential libpq-dev curl postgresql-client dos2unix
```
Solución de fondo pendiente: actualizar la imagen base (Ruby).

### 2. Disco raíz lleno / `data-root` de Docker

`/` (partición chica) al 100% → "No space left on device". Se movió el
`data-root` de Docker a `/home`:
```bash
sudo systemctl stop docker
sudo mkdir -p /home/docker-data
echo '{"data-root": "/home/docker-data"}' | sudo tee /etc/docker/daemon.json
sudo systemctl start docker
```
Al 2026-11-24, `/` sigue al 93% en la máquina de Pablo: vigilar.

### 3. `.env` no define `PG_HOST` ni `POSTGRES_USERNAME`

`config/database.yml` (dev/test) las espera; `.env` define `POSTGRES_USER`
y no tiene `PG_HOST`. La base de `test` intentaba conectar por socket
local. Resuelto en `docker-compose.override.yml`.

### 4. `node_modules` tapado por el bind mount

`.:/app` tapa el `node_modules` de la imagen → `webpack-dev-server not
found`. Resuelto corriendo `yarn install` dentro del contenedor una vez.

### 5. Nombre de imagen duplicado en Kamal

`image: ghcr.io/kleer-colombia/repartelo` generaba
`ghcr.io/ghcr.io/...`: Kamal ya antepone `registry.server`. Corregido a
`image: kleer-colombia/repartelo`.

### 6. Variables de la app que faltaban en el deploy

`ALEGRA_EMAIL`, `ALEGRA_TOKEN` y `ALLOWED_ORIGINS` las usa el código pero
no estaban en `config/deploy.yml`. Las de Alegra se agregaron a
`env.secret` y a `.kamal/secrets*`. `ALLOWED_ORIGINS` también se agregó,
pero el 2026-11-25 se sacó: pasarla vacía hacía que la app recibiera `""`
en vez de caer al `'*'` que usa Heroku (donde no está definida).

### 7. Versión de Postgres

`deploy.yml` tenía `postgres:13`, pero Heroku está en 17.10 y un dump de 17
no se restaura en 13. Cambiado a `postgres:17` antes de crear la base.

### 8. `permission_denied: create_package` al pushear a GHCR

`pablotortorella` era colaborador externo de Kleer-Colombia, y GitHub no
deja que un colaborador externo cree paquetes en la organización. Santi
(owner) invitó a Pablo y Leo como owners; una vez aceptada la invitación
(estado `active`) el push funcionó. Verificar con
`gh api user/memberships/orgs/Kleer-Colombia --jq .state`.

### 9. Heroku CLI

No está en snap. Se instaló con el instalador oficial:
`curl https://cli-assets.heroku.com/install.sh | sh`. El login es por
navegador (`heroku login`); usuario y contraseña no funcionan por el MFA.

### 10. Staging no podía usar la imagen de producción

Con `service: repartelo-staging`, `kamal deploy -d staging --skip-push
--version <versión de prod>` fallaba: `Image ... is missing the 'service'
label`. Kamal etiqueta la imagen con el service que la buildeó y solo la
corre en ese service. Solución: staging usa el **mismo** `service` que
producción (`repartelo`); Kamal ya separa los contenedores por destino
(`repartelo-web-staging-…`). Para que el Postgres de staging no pasara a
llamarse `repartelo-postgres` (¡el de producción!), se fijó
`accessories.postgres.service: repartelo-staging-postgres` en
`config/deploy.staging.yml`, que conserva contenedor y datos existentes.
Verificado con `kamal accessory details postgres [-d staging]` antes de
desplegar.

### 11. Bots escaneando los dominios nuevos

Apenas se emitieron los certificados (que son públicos), empezaron a llegar
requests de bots buscando `/.env`, `/backup.sql`, `/.ssh/id_rsa`,
`/wp-config.php`, etc. Todos responden 404 (`RoutingError` en el log, con
stack trace de varias líneas: infla el conteo de "errores"). No es un
problema de la app. Para buscar errores reales:
`kamal app logs | grep -E "FATAL|ERROR" | grep -v RoutingError`.


### 12. Respuestas lentas / pantallas vacías (latencia + JSON sin comprimir)

Síntoma (2026-11-25): Balances tardaba mucho más que en Heroku y Saldos
mostraba `undefined` / "Sin Datos". Rails generaba las respuestas en
<1 s, pero `kamal-proxy` registraba 24–26 s para entregar
`/api/v1/balance` (415 KB) y >2 min, con algunos 500, para los saldos
grandes (hasta 710 KB). Las respuestas cortadas dejaron la caché del
navegador inconsistente (después llegaban 304 sin nada útil); se arregló
del lado del usuario con Ctrl+Shift+R.

Causas:
- **Ubicación**: el server está en **Helsinki** (`hel1`): ~165 ms de RTT
  desde Colombia, contra ~10 ms de Heroku. Con respuestas grandes y algo de
  pérdida de paquetes, la descarga se desploma. Se evaluó mover el server a
  Hetzner Ashburn (US); **decisión 2026-11-25: se queda en Helsinki** (con
  compresión + mejoras de rendimiento la app anda bien).
- **JSON sin comprimir**: los assets (JS/CSS) ya van en gzip, pero las
  respuestas de la API no.

Arreglo de compresión: `Rack::Deflater` en
`config/environments/production.rb`, insertado antes de
`Rack::ConditionalGet` (el ETag se calcula sobre el JSON sin comprimir, así
que es estable y los 304 siguen funcionando). Resultado en staging:
`balance` 415 → 75 KB, `saldos/6` 710 → 129 KB (−82%); JSON descomprimido
idéntico al de producción; prueba de UI (Balances + Saldos) sin errores.

Mejoras de rendimiento adicionales (mismo día, misma versión que la
compresión):
- **N+1 en la lista de balances** (`BalanceActions#find_all_balances`):
  `Balance.includes(:incomes)`. 717 queries → 2; 0,80 s → 0,34 s.
- **N+1 en saldos** (`SaldosActions#find_saldos` y
  `#find_saldos_of_balances`): `.includes(:balance)`. KleerCo: 745 queries
  → 2; 1,09 s → 0,55 s.
- **Saldos carga solo la pestaña activa** (`Saldos.vue`, `el-tab-pane
  lazy`): antes, al entrar, se pedían los 15 kleerers a la vez (y la app
  corre en un solo proceso). Ahora 1 pedido al entrar y 1 por pestaña la
  primera vez que se abre.

Verificación en staging: las 17 respuestas afectadas (`balance`, los 15
`saldos/:id` y `objectives/reports`) son idénticas byte a byte antes y
después del cambio. En navegador: Balances 2,4 s → 1,9 s; Saldos 3,8 s
(15 pedidos) → 1,4 s (1 pedido); abrir otra pestaña por primera vez
cuesta ~0,6 s (antes ya estaba precargada).

Paginación ("últimos meses" + "cargar más") se evaluó y se descartó por
ahora: el filtro, los checks Abiertos/Cerrados y el orden de Balances
funcionan en el navegador sobre todos los balances, y paginar los
rompería (o habría que llevar la búsqueda al servidor); un balance abierto
viejo quedaría oculto. Reevaluar solo si sigue lento tras estas mejoras y
el cambio de ubicación del server.

Hallazgo de paso: `config/puma.rb` no configura `workers`, así que
`WEB_CONCURRENCY` no tiene efecto y la app corre en un solo proceso con
5 hilos (igual que en Heroku). No fue la causa de esto; queda anotado.

---

## 8. Bitácora

- **2025-05**: Heroku pasa a deploy por contenedor (`heroku.yml` + `Dockerfile`).
- **2026-07**: entorno local dockerizado; scaffolding de Kamal
  (`config/deploy.yml`, `.kamal/secrets`, ruta `/up`); cuenta de Hetzner.
- **2026-11-24**:
  - Verificado el entorno local (app 200, `/up` OK, sin migraciones pendientes).
  - Server creado (Pablo + Leo), firewall, Docker.
  - Arreglos: Debian archive, nombre de imagen, variables faltantes, Postgres 17.
  - Postgres de producción y staging levantados en Hetzner.
  - Backup de Heroku descargado, verificado y cargado en producción;
    staging copiado de producción.
  - Backups diarios con rotación de 5 instalados y probados.
  - Bloqueado el deploy de la app por permisos de GHCR en Kleer-Colombia.
- **2026-11-25**:
  - DNS creado: `r.kleer.la` (prod) y `qa.r.kleer.la` (staging) → `2.29.193.202`.
    Configurados como `proxy.host` con `ssl: true`.
  - `ALLOWED_ORIGINS` deja de pasarse (paridad con Heroku, que no la define).
  - Santi invita a Pablo y Leo como owners de Kleer-Colombia; aceptada.
  - Primer deploy de **producción** (`kamal setup`): https://r.kleer.la OK
    (HTTPS, `/up`, home, lee la base con los datos de Heroku).
    ⚠️ Se hizo antes que staging, contra el criterio del proyecto; de ahí
    sale la regla staging → producción.
  - Staging pasa a compartir `service` con producción (incidencia 10) y se
    despliega con la misma imagen: https://qa.r.kleer.la OK, usando
    `repartelo_staging`.
  - Regla staging → producción en `CLAUDE.md` + hook `pre-deploy` probado.
  - Login: el problema era la contraseña escrita (en Heroku la completaba el
    navegador); el hash es idéntico en ambos lados. Se puso una contraseña
    temporal al usuario de administración en prod y QA (a cambiar).
  - Lentitud/pantallas vacías: diagnóstico en incidencia 12.
  - **Primer pasaje completo staging → producción** con la regla: versión
    `…_uncommitted_babb40f9a09b59f1` (gzip + N+1 + Saldos lazy). Probada en
    QA (datos idénticos, UI OK, "QA vuela" según Pablo), OK de Pablo, y
    promovida con `--skip-push --version`; el hook verificó la versión.
    Resultado en prod: Balances 2,4 → 1,8 s; Saldos 3,8 → 1,4 s.
  - Nota: la primera carga justo después de un deploy es lenta (arranque en
    frío, ~7–13 s); desde la segunda, normal.
  - Decisión: el server se queda en Helsinki.
  - Alegra configurado (credenciales de Heroku) en staging → probado (trae
    facturas abiertas) → producción (antes 401, ahora OK).
  - Commit de todo lo anterior; Kamal vuelve a buildear desde git.

## 9. Checklist del corte (cuando todo lo anterior esté ✅)

1. ✅ App de producción y staging desplegadas en Hetzner con HTTPS.
   ⬜ Prueba funcional con usuarios en staging.
2. ✅ Alegra configurado y probado. ⬜ Decidir CORS.
3. ✅ Commit + sacar `builder.context: .`. ⬜ Redeploy desde un commit (staging → prod).
4. Usar el `SECRET_KEY_BASE` de Heroku en `.env.kamal` (sesiones).
5. Avisar a los usuarios de la nueva URL: **https://r.kleer.la**.
6. `heroku maintenance:on`, refrescar datos (sección 6), promover la
   versión validada en staging (sección 4), `db:migrate`, prueba de humo.
7. Ventana de paralelismo con Heroku en mantenimiento (no apagado) por si
   hay que volver atrás.
8. Último backup de Heroku guardado fuera de Heroku; apagar dynos y
   add-ons de `repartelo2` y `repartelo2-staging`.
