class APageObject
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
    path = "features/screenshots/#{scenario.__id__}.png"
    @page.driver.browser.save_screenshot(path)
  end

  def print_page
    puts @page.body
  end

end