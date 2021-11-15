class BalanceDetailPageObject < APageObject

  def find_project
    @page.find("#project").text
  end
  def find_client
    @page.find("#client").text
  end
  def find_description
    @page.find("#description").text
  end
  def find_date
    @page.find("#date").text
  end
  def find_error
    @page.find(".el-message--error",wait: 5).text
  end

  def find_total_incomes
    @page.find("#moneyingresos",wait: 5).text
  end

  def find_total_expenses
    @page.find("#moneyegresos",wait: 5).text
  end

  def find_total_profit
    @page.find("#moneyutilidad",wait: 5).text
  end

  def add_income income
    sleep(1)
    @page.click_button("nuevo ingreso")
    fill_field("incomeDescription", "prueba ingreso")
    fill_field("incomeAmount", income)
    @page.click_button("saveIncome")
  end

  def select_invoice(invoice_id)
    @page.click_button("Buscar factura")
    #@page.find(:css, 'td.el-table_2_column_3', text: /^#{invoice_id}$/).click
    @page.find('#tableInvoice').all('td').each do |td|
      next unless td.text == "#{invoice_id.to_s} (#{invoice_id.to_s})"
      td.click
    end
    @page.click_button('Agregar')

  end

  def remove_income income
    @page.click_button("removeIncome#{income}")
  end

  def add_expense expense
    sleep(1)
    @page.click_button("nuevo egreso")
    fill_field("expenseDescription", "prueba gasto")
    fill_field("expenseAmount", expense)
    @page.click_button("saveExpense")
  end

  def remove_expense expense
    @page.click_button("removeExpense#{expense}")
    @page.click_button("Aceptar")
  end

  def select_kleerer kleerer
    @page.find("#app").click
    @page.find_by_id("check#{kleerer}").click
  end

  def set_percentage kleerer,amount
    @page.fill_in("inputPercentage#{kleerer}", {:name => "inputPercentage#{kleerer}", :with => amount})
    @page.find("#app").click
  end

  def distribute
    sleep(1)
    @page.click_button("Distribuir")
  end

  def find_amount_to kleerer
    @page.find_by_id("money#{kleerer}").text
  end

  def delete_balance
    @page.click_button("Borrar")
  end

  def confirm_delete_balance
    @page.click_button("Aceptar")
    return BalancePageObject.new @page
  end

  def send_to_saldos
    @page.click_button("Enviar a saldos")
    @page.click_button("Aceptar")
  end

  def coaching_balance?
    @page.has_selector?('#admin-coaching')
  end

  def open_coaching_sessions_admin
    @page.click_button('Administrar sessiones de coaching')
    return CoachingSessionAdminPageObject.new @page
  end

  def find_summary_sessions(kleerer)
    @page.find_by_id("#{kleerer}_sessions").text
  end

  def find_summary_percentage(kleerer)
    @page.find_by_id("#{kleerer}_percentage").text
  end

end
