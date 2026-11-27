class FeatureFlag < ApplicationRecord

  def self.enable? feature
    feature = find_by(feature: feature)
    feature ? feature.status : false
  end
end
