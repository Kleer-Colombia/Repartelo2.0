# Handoff — lo que queda pendiente fuera de un PR

Solo lo que no vive en un PR de GitHub: tareas, pruebas o decisiones
pendientes. Cada asunto es un bloque **Qué / Falta / Cuidado / Fecha**. Se
actualiza cuando cambia su estado (no al final de la sesión) y lo terminado
se borra de acá: su registro queda en [STATUS](STATUS.md) y en el PR. Los
pendientes de infraestructura siguen en
[MIGRACION_HETZNER.md](MIGRACION_HETZNER.md#pendientes-que-no-bloquean).

## Facturas FEKL10761 y FEKL10762 sin XML en el Drive

- **Qué:** están abiertas en Alegra pero no tienen XML en el Drive de
  contabilidad, así que no aparecen en Pagos ni en "Buscar factura".
- **Falta:** que Administración (Ginneth) suba el XML de cada una. La próxima
  lectura del Drive (automática al abrir Pagos, o "Leer Drive ahora") las trae.
- **Cuidado:** si en vez del XML sube solo el PDF, Repártelo no las ve.
- **Fecha:** 2026-11-27.

## Balance #3882 (producción) con la distribución desactualizada

- **Qué:** balance abierto cuya tabla de distribución no coincide con la
  utilidad + clearings (algo cambió después de "Distribuir").
- **Falta:** tocar "Distribuir" antes de enviarlo a saldos (la validación del
  PR #64 no deja enviarlo así).
- **Cuidado:** —
- **Fecha:** 2026-11-27.

## Primera factura emitida con Contapyme

- **Qué:** todo lo probado hasta ahora son XML generados por Alegra. El
  formato lo fija la DIAN, pero falta ver uno real de Contapyme.
- **Falta:** cuando Ginneth suba la primera, comprobar que aparece en Pagos
  con número, cliente y total correctos (`DriveFile.where(status: 'error')`
  si no aparece), y si el XML informa retenciones (se precargan en Pagos).
  Si cambian el prefijo o la estructura de carpetas, revisar
  `DriveInvoiceSync`.
- **Cuidado:** también confirmar que las notas crédito de Contapyme citan el
  CUFE y dicen "Anulación" cuando anulan (si no, no se cruzan).
- **Fecha:** 2026-11-27.

## Dar de baja Alegra

- **Qué:** Repártelo ya no usa Alegra en el día a día; solo la tarea
  `facturas:migrar_alegra`, que ya corrió en producción y staging.
- **Falta:** decisión de Pablo/Administración. Después: quitar
  `ALEGRA_EMAIL`/`ALEGRA_TOKEN` de `config/deploy.yml`, `.kamal/secrets*` y
  `.env.kamal`, y el código de migración (`AlegraClient`, `MigrateFromAlegra`).
- **Cuidado:** sin Alegra la migración no se puede volver a correr (no hay
  otra forma de pasar ids viejos de Alegra a números de factura).
- **Fecha:** 2026-11-27.

## 23 balances cerrados con la distribución distinta de la utilidad

- **Qué:** balances cerrados históricos cuya tabla de distribución no
  coincide con utilidad + clearings (el mismo problema que arregló el PR #64,
  de antes de ese arreglo).
- **Falta:** decidir si se revisan. Se listan con
  `Balance.where(editable: false).reject { |b| b.distributions.empty? || b.distribution_check[:ok] }`.
- **Cuidado:** sus saldos ya se repartieron; no tocarlos sin acuerdo.
- **Fecha:** 2026-11-27.

## Imagen de desarrollo local desactualizada

- **Qué:** `at_repartelo-repartelo` no tiene las gemas actuales (Rails
  5.2.8.1, puma 6, pdf-reader…). Ver incidencia 14 en MIGRACION_HETZNER.md.
- **Falta:** `docker compose build repartelo` ahora que hay espacio en el
  disco; después se puede sacar el `command:` con `bundle install` de
  `docker-compose.override.yml`.
- **Cuidado:** el contenedor monta solo la carpeta principal; no recrearlo
  mientras otra sesión lo usa.
- **Fecha:** 2026-11-27.
