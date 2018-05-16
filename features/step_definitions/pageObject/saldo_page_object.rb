class SaldoPageObject < APageObject
  def initialize page
    super
  end

  def has_kleerer? kleerer_name
    @page.find("#tab-#{kleerer_name}") != nil
  end

  def select_kleerer kleerer_name
    @page.find("#tab-#{kleerer_name}").click
  end

  def find_total
    @page.find("#total").text
  end

  def find_ingresos
    @page.find("#ingresos").text
  end

  def find_egresos
    @page.find("#egresos").text
  end

end