class FeatureFlag < ApplicationRecord

  ALEGRA_INVOICE_MOCK = "alegra-invoices-mock"

  def self.enable? feature
    feature = find_by(feature: feature)
    feature ? feature.status : false
  end
end
