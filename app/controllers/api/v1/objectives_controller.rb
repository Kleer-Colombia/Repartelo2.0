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
          response = @actions.find_saldos_of_balances kleerCo_id
          send_response response
        rescue StandardError => error
          halt_message("can't find kleerCo report: #{error.message}", :internal_server_error)
        end
      end

      def find_kleerers_inputs
        kleerers = []
        Kleerer.all.each do |kleerer|
          if kleerer.option.name.include? "meta"
            kleerers.push({
                            name: kleerer.name,
                            inputs: []
                          })

          end

          saldos = Saldo.where(kleerer_id: kleerer.id)
          saldos_by_year = separate_in_years saldos

          puts saldos_by_year
        end
        puts kleerers
      end

      private

      #TODO: year and month saldos as a service
      def separate_in_years data
        years = {}
        data.each do |saldo|
          years = get_one_year_saldos saldo, years
        end
        return years
      end

      def get_one_year_saldos saldo, years
        date = saldo.created_at.strftime('%Y')
        unless years[date]
          years[date] = []
        end
        if saldo.balance
          years[date].push saldo
        end

        return years
      end

    end
  end
end
