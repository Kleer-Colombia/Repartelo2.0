module ServiceExamples
  class SuccessfulService
    prepend Service
    def call; end
  end

  class SuccessfulServiceWithParameters
    prepend Service
    attr_accessor :param1, :param2
    def initialize(param1, param2)
      @param1 = param1
      @param2 = param2
    end

    def call
      @param1 = @param1.reverse
      @param2 = @param2.reverse
    end
  end

  class FailureService
    prepend Service
    def call
      errors.add(:messages, 'generic error')
    end
  end

  class SuccessfulComposedService
    prepend ComposedService

    def initialize
      super
      add_service(SuccessfulService.new)
      add_service(SuccessfulServiceWithParameters.new('1','2'))
    end
  end

  class FailureComposedService
    prepend ComposedService
    def initialize
      super
      add_service(SuccessfulService.new)
      add_service(FailureService.new)
      add_service(SuccessfulServiceWithParameters.new('1','2'))
    end
  end

  class TreeComposedService
    prepend ComposedService
    def initialize
      super
      add_service(SuccessfulComposedService.new)
      add_service(FailureComposedService.new)
    end
  end


end