module ComposedService
  prepend Service

  attr_reader :sub_services
  attr_reader :results

  def initialize(*args)
    super(*args)
    @results = {}
  end

  def add_service(service)
    (@sub_services ||= []) << service
    service.parent = self
  end

  def remove_service(service)
    @sub_services.delete(service)
    service.parent = nil
  end

  def call
    @sub_services.each do |sub_services|
      sub_services.call
      write_log("called service #{sub_services.class}")
      if (sub_services.success?)
        @results[sub_services.class] = sub_services.result
      else
        errors.add_multiple_errors(sub_services.errors)
        write_log("errors on #{sub_services.class}: #{sub_services.errors}")
        break
      end
    end
    super
  end
end
