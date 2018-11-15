module CompoundService
  prepend Service

  def initialize
    super
    @sub_services = []
  end

  def add_service(service)
    @sub_services << service
    service.parent = self
  end

  def remove_service(service)
    @sub_services.delete(service)
    service.parent = nil
  end

  def call
    @sub_services.each do |sub_services|
      sub_services.call
      unless sub_services.success?
        errors.add_multiple_errors(sub_services.errors)
      end
    end
  end
end