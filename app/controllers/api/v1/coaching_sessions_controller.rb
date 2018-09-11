module Api
  module V1
    class CoachingSessionsController < ApiController
      before_action only: [:update, :destroy, :index, :create]

      def create

        validate_parameters [:balanceId, :coaching_session], params do
          begin
            @coaching_session = CoachingSession.new(
                complementary: params[:coaching_session][:complementary],
                description: params[:coaching_session][:description],
                date: Date.strptime(params[:coaching_session][:date], '%Y-%m-%d')
            )
            @coaching_session.balance_id = params[:balanceId]
            puts params[:coaching_session][:kleerers]
            params[:coaching_session][:kleerers].each do |kleerer_id|
              @coaching_session.kleerers << Kleerer.find(kleerer_id)
            end

            @coaching_session.save!
            send_response @coaching_session.id
          rescue StandardError => error
            puts error
            halt_message 500, "Invalid parameters creating coaching session #{error}"
          end
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


    end
  end
end


