class ReportsPageObject < APageObject
  def initialize(page)
    super
  end

  def find_kleerco_total
    @page.find("#ingresos-kleerco")
  end
end
