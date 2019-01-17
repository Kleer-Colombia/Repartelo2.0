class FindFeatureFlags
  prepend Service

  def initialize; end

  def call
    prepare_feature_flags FeatureFlag.all
  rescue StandardError => e
    errors.add(:messages, "We can't get the feature flags: #{e.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def prepare_feature_flags(feature_flags)
    data = {}
    feature_flags.each do |feature_flag|
      data[feature_flag.feature] = feature_flag.status
    end
    data
  end
end