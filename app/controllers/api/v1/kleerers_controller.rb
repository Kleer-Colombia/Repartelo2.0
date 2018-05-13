module Api
  module V1
    class KleerersController < ApplicationController
      before_action :set_kleerer, only: [:show, :update, :destroy]

      # GET /kleerers
      def index
        @kleerers = Kleerer.all

        render json: @kleerers
      end

      # GET /kleerers/1
      def show
        render json: @kleerer
      end

      # POST /kleerers
      def create
        @kleerer = Kleerer.new(kleerer_params)

        if @kleerer.save
          render json: @kleerer, status: :created, location: @kleerer
        else
          render json: @kleerer.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /kleerers/1
      def update
        if @kleerer.update(kleerer_params)
          render json: @kleerer
        else
          render json: @kleerer.errors, status: :unprocessable_entity
        end
      end

      # DELETE /kleerers/1
      def destroy
        @kleerer.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_kleerer
          @kleerer = Kleerer.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def kleerer_params
          params.require(:kleerer).permit(:name)
        end
    end
  end
end