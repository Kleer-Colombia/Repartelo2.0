module Api
  module V1
    class FeatureFlagController < ApiController
      def find_feature_flags
          execute_command(FindFeatureFlags.new())
      end
    end
  end
end