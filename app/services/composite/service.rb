module Service
  prepend SimpleCommand

  attr_reader :errors
  attr_accessor :parent,:log

  def initialize(*args)
    @parent = nil
    @log = []
    super
  end

  def write_log(message)
    log = @log
    if(@parent)
      log = @parent.log
    end
    log << message
  end

end