# Registro de cada archivo/carpeta del Drive de contabilidad que la
# sincronización ya vio, para no volver a descargarlo.
class DriveFile < ApplicationRecord
  KINDS = %w[invoice_xml credit_note folder other].freeze
  STATUSES = %w[processed ignored error done].freeze

  belongs_to :sales_invoice, optional: true

  validates :drive_id, presence: true, uniqueness: true
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }

  scope :credit_notes, -> { where(kind: 'credit_note', status: 'processed') }
end
