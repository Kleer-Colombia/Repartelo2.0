class ComposedService < CompoundService
  def initialize
    super
    add_service(SimpleService.new)
    add_service(Service.new)
  end

  def call
    puts "composed"
    super
  end
end