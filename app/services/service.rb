class Service
  prepend SimpleCommand

  attr_accessor :parent
  def initialize
    @parent = nil
  end

  def call
    puts self.class
  end
end