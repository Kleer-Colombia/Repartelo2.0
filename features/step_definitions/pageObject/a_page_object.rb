require 'active_support/all'

module BeforeEach
  extend ActiveSupport::Concern

  module InstanceMethods
    def before_each
      raise NotImplementedError('Please define before_each method')
    end
  end

  module ClassMethods
    def method_added(method)
      method = method.to_s.gsub(/_with(out)?_before$/, '')
      with_method, without_method = "#{method}_with_before", "#{method}_without_before"

      return if method == 'before_each' or method_defined?(with_method)

      define_method(with_method) do |*args, &block|
        before_each
        send(without_method, *args, &block)
      end
      alias_method_chain(method, :before)
    end
  end
end

class APageObject


  def before_each
    puts "Before Method" #this is supposed to be invoked by each extending class' method
  end

  def initialize page
    @page = page
  end

  def fill_field name, value
    @page.fill_in(name,{:name => name, :with => value})
  end

  def fill_date(id, value, parent=nil)
    element = @page.find("##{id}")
    element.set(value)
    element.native.send_keys(:return)

  end


  def find_error
    @page.find(".el-message__content", wait: 10).text
  end

  def go_for option
    sleep(1)
    @page.find("##{option}").click

    if option == 'Saldos'
      SaldoPageObject.new @page
    elsif option == 'Balances'
      BalancePageObject.new @page
    elsif option == 'Impuestos'
      TaxPageObject.new @page
    end
  end

  def find_title
    @page.find("#titulo").text
  end

  def editable?(key)
    component = @page.find_by_id(key)
    value = component[:disabled]
    #for check-box
    if !value
      value = component['aria-disabled']
    end
    !value
  end

  def take_screenshot(scenario)
    path = "#{__dir__}../../../screenshots/#{scenario.__id__}.png"
    @page.save_screenshot(path)
  end

  def print_page
    puts @page.body
  end



end