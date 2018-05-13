class Book < ApplicationRecord
  belongs_to :kleerer
  monetize :price_cents

  validates :title, presence: true

  def to_s
    title
  end
end
