class NewBalancePageObject < APageObject

  def create_balance client, proyecto, description,date
    fill_field('client', client)
    fill_field('project', proyecto)
    fill_date('date', "#{date.year}-#{date.month}-#{date.day}")
    fill_field('description',description)
  end

  def save_balance
    @page.click_button("Guardar")
    return BalanceDetailPageObject.new @page
  end
end