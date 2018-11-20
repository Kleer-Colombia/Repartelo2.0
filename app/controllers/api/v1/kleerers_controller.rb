module Api
  module V1
    #TODO cached this service
    class KleerersController < ApiController

      def find_all
        send_response(prepare_info(Kleerer.all))
      end

      def find_without_co
        send_response(prepare_info(Kleerer.where.not(name: 'KleerCo')))
      end

      private

      def prepare_info(kleerers)
        data = []
        kleerers.each do |kleerer|
          kjson = {}
          kjson['id'] =  kleerer.id
          kjson['name'] =  kleerer.name
          kjson['option'] =  kleerer.option.name
          data << kjson
        end
        data
      end
    end
  end
end