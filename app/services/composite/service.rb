module Service
  prepend SimpleCommand

  attr_reader :errors
  attr_accessor :parent

  def initialize(*args)
    @parent = nil
    super
  end

end