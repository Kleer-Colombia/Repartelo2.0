namespace :sequence do
  desc "Sincroniza la secuencia de balances_id_seq con el valor máximo de id en balances y registra el cambio"
  task sync: :environment do
    current_seq = ActiveRecord::Base.connection.execute("SELECT last_value FROM balances_id_seq").first['last_value'].to_i
    max_id = ActiveRecord::Base.connection.execute("SELECT MAX(id) FROM balances").first['max'].to_i + 1

    if current_seq < max_id
      ActiveRecord::Base.connection.execute("SELECT setval('balances_id_seq', #{max_id});")
      puts "Secuencia sincronizada a #{max_id}"

      SequenceLog.create(change_reason: "Scheduled sync", old_value: current_seq, new_value: max_id)
    end
  end
end
