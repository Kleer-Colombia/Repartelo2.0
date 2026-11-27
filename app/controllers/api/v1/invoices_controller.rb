module Api
  module V1
    # Facturas de venta (vienen del Drive de contabilidad).
    class InvoicesController < ApiController
      # "Buscar factura" en un balance.
      def find_available
        execute_command(FindAvailableInvoices.new)
      end

      # Fuerza una sincronización con el Drive (ignora la última corrida).
      def sync
        return halt_message('Falta configurar la carpeta del Drive (DRIVE_CONTABILIDAD_FOLDER_ID)', :service_unavailable) unless DriveInvoiceSync.configured?

        run = DriveInvoiceSync.new(mode: 'incremental').call
        send_response(run.as_summary)
      end
    end
  end
end
