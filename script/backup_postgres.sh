#!/usr/bin/env bash
# Backup diario de la base de Repártelo en el server de Hetzner.
#
# Hace un pg_dump (formato custom, comprimido) desde el contenedor del
# accessory de Postgres que levanta Kamal, verifica que el archivo se pueda
# leer con pg_restore y deja solo los últimos $KEEP backups.
#
# Instalación en el server (una sola vez, como root):
#   scp script/backup_postgres.sh root@SERVER:/usr/local/bin/repartelo-backup
#   ssh root@SERVER 'chmod 700 /usr/local/bin/repartelo-backup'
#   ssh root@SERVER 'echo "0 7 * * * root /usr/local/bin/repartelo-backup >> /var/log/repartelo-backup.log 2>&1" > /etc/cron.d/repartelo-backup'
# (07:00 UTC = 02:00 en Bogotá; el server está en UTC.)
#
# Restaurar un backup:
#   docker exec -i repartelo-postgres pg_restore -U repartelo -d repartelo_production --clean --if-exists --no-owner < ARCHIVO.dump
#
# Todo es configurable por variables de entorno (útil para probarlo en local).

set -euo pipefail

CONTAINER="${CONTAINER:-repartelo-postgres}"   # nombre que le da Kamal al accessory
DB_NAME="${DB_NAME:-repartelo_production}"
DB_USER="${DB_USER:-repartelo}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/repartelo}"
KEEP="${KEEP:-5}"

log() { echo "[$(date -u '+%F %T UTC')] $*"; }

umask 077
mkdir -p "$BACKUP_DIR"

# Evita dos corridas simultáneas (ej. una manual mientras corre el cron).
exec 9>"$BACKUP_DIR/.lock"
if ! flock -n 9; then
  log "ERROR: ya hay un backup en curso, salgo."
  exit 1
fi

stamp="$(date -u '+%Y-%m-%d_%H%M%S')"
final="$BACKUP_DIR/${DB_NAME}_${stamp}.dump"
tmp="$final.partial"
trap 'rm -f "$tmp"' EXIT

log "Iniciando backup de $DB_NAME (contenedor $CONTAINER)"

# Conexión por socket local dentro del contenedor: la imagen oficial de
# postgres permite "trust" ahí, así que no hace falta la contraseña.
docker exec "$CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" --format=custom --no-owner --no-acl > "$tmp"

# Un dump vacío o corrupto no debe contar como backup ni desplazar a los buenos.
if [ ! -s "$tmp" ]; then
  log "ERROR: el dump quedó vacío."
  exit 1
fi
if ! docker exec -i "$CONTAINER" pg_restore --list < "$tmp" > /dev/null; then
  log "ERROR: pg_restore no puede leer el dump, lo descarto."
  exit 1
fi

mv "$tmp" "$final"
trap - EXIT
log "OK: $final ($(du -h "$final" | cut -f1))"

# Rotación: el nombre lleva fecha/hora UTC, así que el orden alfabético es el
# cronológico. Se borran todos menos los $KEEP más nuevos.
mapfile -t old < <(ls -1 "$BACKUP_DIR"/"${DB_NAME}"_*.dump 2>/dev/null | sort | head -n -"$KEEP")
for f in "${old[@]}"; do
  rm -f -- "$f"
  log "Borrado backup viejo: $(basename "$f")"
done

log "Backups disponibles: $(ls -1 "$BACKUP_DIR"/"${DB_NAME}"_*.dump | wc -l)"
