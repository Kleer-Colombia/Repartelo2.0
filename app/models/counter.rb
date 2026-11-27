# Contador sin huecos (ver db/migrate/20261127150000_create_counters.rb).
class Counter < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  # Devuelve el próximo valor del contador `name`.
  #
  # Tiene que llamarse dentro de la transacción que usa el número: el UPDATE
  # deja la fila bloqueada hasta el commit (altas concurrentes esperan su
  # turno) y un rollback devuelve el número, así no quedan huecos.
  #
  # Si la fila no existe (p. ej. una base creada con db:schema:load), la crea
  # arrancando desde `start_after`.
  def self.next_value!(name, start_after: 0)
    sql = sanitize_sql_array([<<~SQL, name, start_after.to_i])
      INSERT INTO counters (name, value, created_at, updated_at)
      VALUES (?, ? + 1, NOW(), NOW())
      ON CONFLICT (name)
      DO UPDATE SET value = counters.value + 1, updated_at = NOW()
      RETURNING value
    SQL
    connection.select_value(sql).to_i
  end
end
