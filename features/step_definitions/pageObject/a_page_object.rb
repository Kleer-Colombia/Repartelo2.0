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
    #to get focus
    if parent
      @page.find_by_id(parent).click
    else
      @page.find('#titulo').click
    end
  end

  def go_for option
    @page.find("##{option}").click
    if option == 'Saldos'
      SaldoPageObject.new @page
    elsif option == 'Balances'
      BalancePageObject.new @page
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

end