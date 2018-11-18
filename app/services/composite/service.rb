# frozen_string_literal: true

module Service
  prepend SimpleCommand

  INSPECT = :inspect_on_parameters

  ATTR_EXCLUDED =['called']
  attr_reader :errors
  attr_accessor :parent, :log, :params

  def initialize(*args)
    @parent = nil
    @log = []
    @params = {}
    super(*args)
  end

  def write_log(message)
    log = @log
    log = @parent.log if @parent
    log << message
  end

  def up_parameter(key, value)
    if(@parent)
      @parent.params[key] = value
      puts "upped parameter #{key}: #{value}"
    end
  end

  def down_parameter(key)
    return @parent.params[key] if @parent && @parent.params[key]
    raise StandardError, "you didn't up the parameter '#{key.to_s}' in the previous services commands executions"
  end

  def call
    inspect_and_change_attrs
    super
  end


  def inspect_and_change_attrs
    instance_variables.each do |var|
      var = var.to_s.gsub /^@/, ''
      unless ATTR_EXCLUDED.include? var
        if send(var) == INSPECT
          result = down_parameter(var.to_sym)
          send("#{var}=", result)
        end
      end
    end
  end

end