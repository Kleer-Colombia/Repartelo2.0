class Distribution < ApplicationRecord
  validates :amount, presence: true
  belongs_to :kleerer
  belongs_to :balance


  def self.get_from(balance_id)
    data=[]
    Distribution.where(balance_id:balance_id).each do |distribution|
      data << "#{distribution.kleerer.name}: #{distribution.amount}"
    end
    data.join('||')
  end
end