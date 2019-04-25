# frozen_string_literal: true

class Tax < ApplicationRecord
  validates :name, presence: true
  validates :amount, presence: true
  validates :percentage, presence: true
  belongs_to :balance
end
