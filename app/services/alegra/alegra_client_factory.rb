class AlegraClientFactory

  def self.build
    if FeatureFlag.enable? FeatureFlag::ALEGRA_INVOICE_MOCK
      AlegraClientMock.new
    else
      AlegraClient.new
    end
  end
end
