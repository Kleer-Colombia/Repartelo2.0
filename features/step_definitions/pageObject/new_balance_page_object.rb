class NewBalancePageObject < APageObject

  def create_balance params
    fill_field('client', params[:client])
    fill_field('project', params[:project])
    fill_date('date', "#{params[:date].year}-#{params[:date].month}-#{params[:date].day}")
    fill_field('description',params[:description])
  end

  def save_balance
    @page.click_button("Guardar")
    return BalanceDetailPageObject.new @page
  end
end