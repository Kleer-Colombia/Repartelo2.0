# frozen_string_literal: true
require './spec/services/composite/service_examples'

describe Service do
  context 'simple service' do
    it 'success simple service' do
      service = ServiceExamples::SuccessfulService.new
      service.call
      expect(service.success?).to eq true
    end

    it 'success simple service with parameters' do

      service = ServiceExamples::SuccessfulServiceWithParameters.new('hola', 'mundo')
      service.call
      expect(service.success?).to eq true
      expect(service.param1).to eq 'hola'.reverse
      expect(service.param2).to eq 'mundo'.reverse
    end

    it 'fails simple service' do

      service = ServiceExamples::FailureService.new
      service.call
      expect(service.success?).to eq false
      expect(service.errors[:messages]).to eq ['generic error']
    end
  end

  context ' composite services' do
    it 'must content 2 simple services' do
      service = ServiceExamples::SuccessfulComposedService.new
      expect(service.sub_services.size).to eq 2
    end

    it 'must content 1 simple service when I removed one' do
      service = ServiceExamples::SuccessfulComposedService.new
      service.remove_service(service.sub_services[1])
      expect(service.sub_services.size).to eq 1
      expect(service.sub_services[0].class).to eq ServiceExamples::SuccessfulService
    end

    it 'must call successful' do
      service = ServiceExamples::SuccessfulComposedService.new
      service.call
      expect(service.log.size).to eq 2
      expect(service.log[0]).to eq "called service #{ServiceExamples::SuccessfulService}"
      expect(service.log[1]).to eq "called service #{ServiceExamples::SuccessfulServiceWithParameters}"
    end

    it 'must call successful with shared parameters' do
      service = ServiceExamples::SuccessfulSharedparametersComposedService.new('yamit')
      service.call
      expect(service.log.size).to eq 3
      puts service.log
      expect(service.log[0]).to eq "called service #{ServiceExamples::SuccessfulPushParameterService}"
      expect(service.log[1]).to eq "TIMAY"
      expect(service.log[2]).to eq "called service #{ServiceExamples::SuccessfulUsedPushParameterService}"

    end

    it 'must call and ending with errors' do
      service = ServiceExamples::FailureComposedService.new
      service.call

      expect(service.sub_services.size).to eq 3
      expect(service.log.size).to eq 3
      expect(service.log[0]).to eq "called service #{ServiceExamples::SuccessfulService}"
      expect(service.log[1]).to eq "called service #{ServiceExamples::FailureService}"
      expect(service.log[2]).to eq "errors on #{ServiceExamples::FailureService}: {:messages=>[\"generic error\"]}"
    end

    it 'must call a tree service and ending with errors' do
      service = ServiceExamples::TreeComposedService.new
      service.call

      expect(service.errors[:messages]).to eq ['generic error']
      expect(service.sub_services.size).to eq 2
      expect(service.log.size).to eq 8
      expect(service.log[0]).to eq "called service #{ServiceExamples::SuccessfulService}"
      expect(service.log[1]).to eq "called service #{ServiceExamples::SuccessfulServiceWithParameters}"
      expect(service.log[2]).to eq "called service #{ServiceExamples::SuccessfulComposedService}"
      expect(service.log[3]).to eq "called service #{ServiceExamples::SuccessfulService}"
      expect(service.log[4]).to eq "called service #{ServiceExamples::FailureService}"
      expect(service.log[5]).to eq "errors on #{ServiceExamples::FailureService}: {:messages=>[\"generic error\"]}"
      expect(service.log[6]).to eq "called service #{ServiceExamples::FailureComposedService}"
      expect(service.log[7]).to eq "errors on #{ServiceExamples::FailureComposedService}: {:messages=>[\"generic error\"]}"
    end

  end

end
