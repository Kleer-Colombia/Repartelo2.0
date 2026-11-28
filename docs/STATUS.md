# Estado de Repártelo — publicaciones y verificaciones

Este archivo registra **solo publicaciones y verificaciones**: qué versión
corre en cada ambiente y cómo se comprobó. El estado de los PRs se mira en
GitHub; la operación (cómo se hace cada cosa) está en
[MIGRACION_HETZNER.md](MIGRACION_HETZNER.md); los pendientes, en su sección
"Pendientes". Lo que está en `main` sin publicar no se anota: se calcula.

## Publicado hoy

Comprobado el 2026-11-27 con `kamal app version` / `kamal app version -d staging`.
Al publicar, actualizar la fila del ambiente y agregar la entrada al registro de abajo.

| Ambiente | URL | Versión (SHA de `main`) | Publicada | Base de datos | Verificación |
|---|---|---|---|---|---|
| Producción | https://r.kleer.la | `c0034ba` | 2026-11-27 | Migración más nueva: `20261127160000` (`CreateCounters`) | `/up` 200, home 200, logs sin errores de la app. |
| Staging | https://qa.r.kleer.la | `c0034ba` | 2026-11-27 | **Copia de producción** del 2026-11-27 (30 tablas, 28.664 filas, idénticas) | `/up` 200, home 200. |

**Qué hay en `main` sin publicar** (se calcula, no se anota):

```bash
git fetch origin
git diff --stat c0034ba origin/main -- . ':!docs' ':!*.md'
```

## Registro de publicaciones

Lo más nuevo arriba. Cada entrada lleva: fecha, ambiente, SHA de `main`, PRs,
migraciones y tareas corridas, verificación y quién dio el OK. Lo anterior
al 2026-11-27 (y el detalle de cada día) está en la bitácora de
[MIGRACION_HETZNER.md](MIGRACION_HETZNER.md#8-bitácora).

### 2026-11-27 — staging: base copiada de producción

Después de la prueba de QA de Administración (Ginneth), que dejó en staging
dos balances cerrados (#3882, #3948), 4 saldos y 4 pagos que no están en
producción. Con OK de Pablo.

- `pg_dump -Fc` de `repartelo_production` → `pg_restore --clean --if-exists`
  en `repartelo_staging`, dentro del server (ver MIGRACION_HETZNER.md,
  "Copiar producción a staging").
- Verificado: 30 tablas y 28.664 filas, conteo idéntico tabla por tabla.
- App de staging reiniciada con `kamal app boot -d staging --version c0034ba…`
  (con `--version` explícito: sin él queda reportando `latest-staging` y el
  hook de producción no puede comparar).

### 2026-11-27 — producción y staging: `c0034ba` (PR #63)

Kleerers con nombre único. Sin migraciones. Staging → OK de Pablo → producción.

### 2026-11-27 — producción: `d8afbfd` (PRs #61 y #64)

Facturas de venta desde el Drive de contabilidad (en vez de Alegra),
sección Pagos, y validación de la distribución al enviar a saldos. Probado
en staging por Ginneth; OK de Pablo.

- `db:migrate` con la imagen nueva antes del deploy:
  `CreateSalesInvoices`, `InvoiceNumberInsteadOfAlegraId`.
- `kamal deploy --skip-push --version d8afbfd…` (el hook verificó la versión de staging).
- `facturas:sync_drive_full`: 690 facturas, 101 notas crédito, 69 anuladas, 0 errores.
- `facturas:migrar_alegra`: 855 facturas de balances pasaron a número; 685
  pagadas (origen Alegra); 5 pendientes (FEKL10720, 10756, 10757, 10758,
  10759), todas en balances abiertos; 0 de balances cerrados pendientes.
- `/up` 200, home 200, logs sin errores de la app.

### 2026-11-27 — staging: `d8afbfd` (PR #64) y `aaa2663` (PR #61)

`aaa2663`: migraciones, `facturas:sync_drive_full` y `facturas:migrar_alegra`
(mismos números que producción). Prueba de Ginneth: encontró que se podía
enviar a saldos con la distribución desactualizada → PR #64 → `d8afbfd`, que
volvió a probar.

### 2026-11-27 — anteriores del día

Seguridad (`3d4ba2a`, PR #57), balances consecutivos (`b54234d`, PR #58),
restauración de archivos de Alegra (`67fbb3e`, PR #59, incidencia 13) y
validación de saldos (`550fb72`, PR #60). Detalle en la bitácora.
