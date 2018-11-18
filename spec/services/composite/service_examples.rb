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
      add_service(SuccessfulService.new)
      add_service(SuccessfulServiceWithParameters.new('1','2'))
    end

    def call
      true
    end
  end

  class SuccessfulPushParameterService
    prepend Service
    attr_accessor :param
    def initialize param
      @param = param
    end
    def call
      up_parameter(:name, @param.reverse)
      @param.reverse
    end
  end

  class SuccessfulUsedPushParameterService
    prepend Service
    attr_accessor :name
    def initialize(name)
      @name = name
    end
    def call
      @name.upcase!
    end
  end

  class SuccessfulSharedparametersComposedService
    prepend ComposedService

    def initialize parameter
      add_service(SuccessfulPushParameterService.new(parameter))
      add_service(SuccessfulUsedPushParameterService.new(Service::INSPECT))
    end

    def call
      @results[SuccessfulUsedPushParameterService]
    end
  end

  class FailureComposedService
    prepend ComposedService
    def initialize
      add_service(SuccessfulService.new)
      add_service(FailureService.new)
      add_service(SuccessfulServiceWithParameters.new('1','2'))
    end

    def call
      true
    end
  end

  class TreeComposedService
    prepend ComposedService
    def initialize
      add_service(SuccessfulComposedService.new)
      add_service(FailureComposedService.new)
    end
    def call
      true
    end
  end


end