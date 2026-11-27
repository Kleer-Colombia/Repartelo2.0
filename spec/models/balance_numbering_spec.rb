require 'rails_helper'

describe 'Numeración de balances' do
  def create_balance
    Balance.create!(project: 'project', client: 'client',
                    balance_type: 'standard', date: Date.today)
  end

  it 'asigna números consecutivos aunque la secuencia de Postgres salte' do
    first = create_balance
    # Simula el salto de la secuencia (lo que pasaba en Heroku).
    ActiveRecord::Base.connection.execute(
      "SELECT setval('balances_id_seq', #{first.id + 32})")

    second = create_balance
    third = create_balance

    expect(second.id).to eq first.id + 1
    expect(third.id).to eq first.id + 2
  end

  it 'arranca después del último balance existente si no hay contador' do
    existing = create_balance
    Counter.where(name: 'balances').delete_all

    expect(create_balance.id).to eq existing.id + 1
  end

  it 'no consume número si el alta falla' do
    first = create_balance

    expect {
      ActiveRecord::Base.transaction do
        create_balance
        raise ActiveRecord::Rollback
      end
    }.not_to change { Balance.count }

    expect(create_balance.id).to eq first.id + 1
  end

  it 'no reutiliza el número de un balance borrado' do
    create_balance
    deleted = create_balance
    deleted.destroy!

    expect(create_balance.id).to eq deleted.id + 1
  end
end
