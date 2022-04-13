class DataLoadActions
  def load_expenses data
    data.each do |expense|
      amount =  - expense[:amount].to_f
      date = Date.parse(expense[:date])

      kleerer = Kleerer.find_by(name: expense[:kleerer])
      if kleerer
        saldo = Saldo.new(kleerer_id: kleerer.id, amount: amount, created_at: date,
                          reference: expense[:reference], concept: expense[:concept])
        saldo.save!
      else
        #is tax
        tax_master = TaxMaster.find_by(name: expense[:kleerer])
        if tax_master
          concept = "#{expense[:concept]} #{expense[:reference]}"

          ManualTax.create(concept: concept, amount: amount, date: date, payment_date: date,
                           tax_master_id: tax_master.id)
          # puts "#{date.class} #{date}"
        else
          #not founded
          puts "no encontrado #{expense[:kleerer]}"
        end
      end
    end
    return 'ok'
  end
end
