# frozen_string_literal: true

describe Service do
  it 'success simple service' do
    class SuccessfulService
      prepend Service
      def call; end
    end

    service = SuccessfulService.new
    service.call
    expect(service.success?).to eq true
  end

  it 'success simple service with parameters' do
    class SuccessfulServiceWithParameters
      prepend Service

      attr_accessor :param1, :param2
      def initialize(param1,param2)
        @param1 = param1
        @param2 = param2
      end

      def call
        @param1 = @param1.reverse
        @param2 = @param2.reverse
      end
    end

    service = SuccessfulServiceWithParameters.new('hola', 'mundo')
    service.call
    expect(service.success?).to eq true
    expect(service.param1).to eq 'hola'.reverse
    expect(service.param2).to eq 'mundo'.reverse
  end

  it 'fails simple service' do
    class SuccessfulService
      prepend Service
      def call
        errors.add(:messages, 'generic error')
      end
    end

    service = SuccessfulService.new
    service.call
    expect(service.success?).to eq false
    expect(service.errors[:messages]).to eq ['generic error']
  end
end
