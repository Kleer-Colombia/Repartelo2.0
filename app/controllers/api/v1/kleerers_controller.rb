module Api
  module V1
    class KleerersController < ApplicationController

      def find_all
        send_response Kleerer.all
      end

      def find_without_co
        send_response Kleerer.where.not(name: 'KleerCo')
      end
    end
  end
end