# Una corrida de DriveInvoices::Sync (para mostrar la última sincronización
# y no repetirla en cada consulta).
class DriveSyncRun < ApplicationRecord
  def self.last_finished
    where.not(finished_at: nil).order(finished_at: :desc).first
  end

  def as_summary
    { mode: mode, startedAt: started_at, finishedAt: finished_at, error: error, summary: summary }
  end
end
