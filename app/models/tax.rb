# frozen_string_literal: true

class Tax < ApplicationRecord
  validates :name, presence: true
  validates :amount, presence: true
  validates :percentage, presence: true
end
