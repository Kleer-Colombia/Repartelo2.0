class DataLoadActions

  def initialize
    @report = {
      "taxes_added": 0,
      "saldos_added": 0,
      "errors": 0,
      "detail_errors": []
    }
  end


  def load_expenses data
    data.each do |expense|

      begin
        amount =  - expense[:amount].to_f
        date = Date.parse(expense[:date])

        kleerer = Kleerer.find_by(name: expense[:kleerer])
        if kleerer

          saldo = Saldo.new(kleerer_id: kleerer.id, amount: amount, created_at: date,
                            reference: expense[:reference], concept: expense[:concept])
          saldo.save!

          @report[:saldos_added] += 1

        else
          #is tax
          tax_master = TaxMaster.find_by(name: expense[:kleerer])
          if tax_master
            concept = "#{expense[:concept]} #{expense[:reference]}"

            ManualTax.create(concept: concept, amount: amount, date: date, payment_date: date,
                             tax_master_id: tax_master.id)

            @report[:taxes_added] += 1
          else
            #not founded
            @report[:errors] += 1
            @report[:detail_errors].push("Registro #{expense[:id]} no ubicado en saldos ni impuestos")
          end
        end
      rescue
        @report[:errors] += 1
        @report[:detail_errors].push("Registro #{expense[:id]} error al agregar")
      end

    end

    return @report
  end

  private

  def create_report

  end
end
