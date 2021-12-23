module Api
  module V1
    class ObjectivesController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= SaldosActions.new
      end

      def find_kleerco_reports
        find_kleerers_inputs()
        begin
          kleerCo = Kleerer.find_by(name: "KleerCo")
          kleerCo_id = kleerCo.id
          response = {
            total: @actions.find_saldos_of_balances(kleerCo_id),
            kleerers: find_kleerers_inputs
          }

          send_response response
        rescue StandardError => error
          halt_message("can't find kleerCo report: #{error.message}", :internal_server_error)
        end
      end

      def find_kleerers_inputs
        kleerCo = Kleerer.find_by(name: "KleerCo")
        kleerers = []
        Kleerer.all.each do |kleerer|
          if kleerer.name != kleerCo.name
            kleerers.push(kleerer)
          end
        end

        kleerers_inputs = []
        kleerers.each do |kleerer|
          complete_kleerer_input = {
                  name: kleerer.name,
                  inputs: []
                }

          saldos = Saldo.where(kleerer_id: kleerer.id)
          puts "#{kleerer.id} #{kleerer.name}"

          inputs = []
          years = separate_in_years saldos
          years.each do |year|
            inputs.push({
                          year: year,
                          input: 0
                        })
          end

          saldos.each do |saldo|
            #that could be better
            if saldo.balance_id
              begin
                balance_input = Saldo.find_by(kleerer_id: kleerCo.id, balance_id: saldo.balance_id)
                percentage = Percentage.find_by(kleerer_id: kleerer.id, balance_id: saldo.balance_id)
                input = balance_input.amount * (percentage.value / 100)
                date = saldo.created_at.strftime('%Y').to_i
                inputs.each do |year_input|
                  if year_input[:year] == date
                    year_input[:input] = year_input[:input] + input
                  end
                end
              rescue
                break
              end
            end
          end
          complete_kleerer_input[:inputs] = inputs
          kleerers_inputs.push(complete_kleerer_input)

        end
        kleerers_inputs
      end

      private

      def separate_in_years data
        years = []
        data.each do |saldo|
          years = get_one_year_distributions saldo, years
        end
        years
      end

      def get_one_year_distributions saldo, years
        date = saldo.created_at.strftime('%Y').to_i
        unless years.include? date
          years.push(date)
        end
        years
      end
      end
    end
end
