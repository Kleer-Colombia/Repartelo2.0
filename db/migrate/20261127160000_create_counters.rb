# Numeración consecutiva de balances.
#
# El número de balance es su `id`, y hasta ahora lo daba la secuencia de
# Postgres (`balances_id_seq`). Las secuencias no garantizan números sin
# huecos: Postgres reserva 32 valores por adelantado y los pierde ante un
# reinicio/failover (en Heroku pasaba casi en cada alta: saltos de 33).
#
# `counters` guarda el último número asignado. Se incrementa con un UPDATE
# dentro de la transacción del alta (ver Counter.next_value!): si el alta
# falla, el incremento se deshace, y dos altas simultáneas se serializan.
#
# Se puede volver a correr sin romper (si la tabla ya existe, solo vuelve a
# poner el contador en el último balance), por ejemplo si un restore deja
# la tabla pero no su fila en schema_migrations.
class CreateCounters < ActiveRecord::Migration[5.2]
  def up
    unless table_exists?(:counters)
      create_table :counters do |t|
        t.string :name, null: false
        t.bigint :value, null: false, default: 0
        t.timestamps
      end
      add_index :counters, :name, unique: true
    end

    # El próximo balance es max(id) + 1. Si ya había contador, se pisa con
    # el dato real de los balances (que son los que acaban de restaurarse).
    execute <<~SQL
      INSERT INTO counters (name, value, created_at, updated_at)
      SELECT 'balances', COALESCE(MAX(id), 0), NOW(), NOW() FROM balances
      ON CONFLICT (name) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
    SQL
  end

  def down
    drop_table :counters
  end
end
