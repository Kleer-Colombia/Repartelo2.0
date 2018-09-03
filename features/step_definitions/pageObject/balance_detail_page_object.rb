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
    @page.find("#totalIncomes",wait: 5).text
  end

  def find_total_expenses
    @page.find("#totalExpenses",wait: 5).text
  end

  def find_total_profit
    @page.find("#totalProfit",wait: 5).text
  end

  def add_income income
    @page.click_button("nuevo ingreso")
    fill_field("incomeDescription", "prueba ingreso")
    fill_field("incomeAmount", income)
    @page.click_button("saveIncome")
  end

  def remove_income income
    @page.click_button("removeIncome#{income}")
  end

  def add_expense expense
    @page.click_button("nuevo egreso")
    fill_field("expenseDescription", "prueba gasto")
    fill_field("expenseAmount", expense)
    @page.click_button("saveExpense")
  end

  def remove_expense expense
    @page.click_button("removeExpense#{expense}")
  end

  def calculate_balance kleerer
    @page.find_by_id("check#{kleerer}").click
  end

  def set_percentage kleerer,amount
    @page.fill_in("inputPercentage#{kleerer}", {:id => "inputPercentage#{kleerer}", :with => amount})
    @page.find("#app").click
  end

  def distribute
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
    @page.has_selector?("#admin-coaching")
  end

  def editable? key
    component = @page.find_by_id(key)
    value = component[:disabled]
    #for check-box
    if !value
      value = component['aria-disabled']
    end
    !value
  end
end