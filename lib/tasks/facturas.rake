namespace :facturas do
  desc 'Trae del Drive de contabilidad las facturas nuevas (año actual y anterior)'
  task sync_drive: :environment do
    print_run DriveInvoiceSync.new(mode: 'incremental').call
  end

  desc 'Recorre todo el Drive de contabilidad (todos los años). Para la carga inicial.'
  task sync_drive_full: :environment do
    print_run DriveInvoiceSync.new(mode: 'full').call
  end

  desc 'Migración desde Alegra: números de factura en balances y estado de pago inicial'
  task migrar_alegra: :environment do
    abort 'Faltan ALEGRA_EMAIL / ALEGRA_TOKEN' unless AlegraClient.configured?
    abort 'No hay facturas del Drive: correr antes facturas:sync_drive_full' if SalesInvoice.none?

    MigrateFromAlegra.new.call
  end

  def print_run(run)
    puts "Sincronización #{run.mode}: #{run.error ? "ERROR #{run.error}" : 'OK'}"
    run.summary.except('errors').each { |key, value| puts "  #{key}: #{value}" }
    (run.summary['errors'] || []).each { |e| puts "  ! #{e['where']}: #{e['message']}" }
  end
end
