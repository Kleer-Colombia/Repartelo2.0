
class TaxPageObject < APageObject

  def initialize page
    super
  end

  def find_total_for tax_name
    @page.find("#tab-#{tax_name}").click
    @page.find("#total").text
  end

end