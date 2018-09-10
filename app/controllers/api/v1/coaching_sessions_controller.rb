module Api
  module V1
    class CoachingSessionsController < ApiController
      before_action only: [:update, :destroy, :index, :create]

      def create
        begin
          data = coaching_session_params
          @coaching_session = CoachingSession.new(data)
          @coaching_session.save!
          send_response @coaching_session.id
        rescue StandardError => e
          puts e
          halt_message 500, "Invalid parameters creating balance #{e}"
        end
      end

      # PATCH/PUT /coaching_sessions/1
      def update
        if @coaching_session.update(coaching_session_params)
          redirect_to @coaching_session, notice: 'Coaching session was successfully updated.'
        else
          render :edit
        end
      end

      # DELETE /coaching_sessions/1
      def destroy
        @coaching_session.destroy
        redirect_to coaching_sessions_url, notice: 'Coaching session was successfully destroyed.'
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_coaching_session
        @coaching_session = CoachingSession.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def coaching_session_params
        params.fetch(:coaching_session, {})
      end
    end
  end
end


