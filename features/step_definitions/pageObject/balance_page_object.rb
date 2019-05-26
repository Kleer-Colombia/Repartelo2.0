
class BalancePageObject < APageObject

  def initialize page
    super
  end

  def find_balance_date id
    @page.find("#date#{id}").text
  end

  def find_balance_client id
    @page.find("#client#{id}").text
  end

  def find_balance_description id
    @page.find("#description#{id}").text
  end

  def balance_table_is_empty?
    @page.find(".el-table__empty-text").text == 'Sin Datos'
  end

  def new_balance
    @page.click_button("Nuevo")
    NewBalancePageObject.new @page
  end

  def edit_balance
    @page.click_link("Editar")
    BalanceDetailPageObject.new(@page)
  end
end