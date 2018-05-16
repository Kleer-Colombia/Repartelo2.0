class APageObject
  def initialize page
    @page = page
  end

  def fill_field name, value
    @page.fill_in(name,{:name => name, :with => value})
  end

  def fill_date id, value,focus_on="titulo"
    @page.find("##{id}").set(value)
    #to get focus
    @page.find("##{focus_on}").click
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

end