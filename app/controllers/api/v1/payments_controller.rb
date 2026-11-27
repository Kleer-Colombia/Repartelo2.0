module Api
  module V1
    # Sección Pagos: facturas pendientes de cobro y pagadas.
    class PaymentsController < ApiController
      def index
        execute_command(FindPayments.new(status: params[:status] || 'pending', year: params[:year]))
      end

      # "Fue pagada" (también sirve para corregir un pago).
      def create
        validate_parameters [:number, :payment], params do
          data = params.require(:payment).permit(:paidOn, :amount, :retefuente, :reteica, :reteiva).to_h
          execute_command(RegisterPayment.new(number: params[:number], data: data, user: current_user))
        end
      end

      def destroy
        execute_command(RemovePayment.new(number: params[:number]))
      end
    end
  end
end
