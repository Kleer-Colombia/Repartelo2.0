# frozen_string_literal: true

class DataFactory
  def self.create_one_user
    User.delete_all
    userForLogin = User.new
    userForLogin.name = 'ali cate'
    userForLogin.email = 'ali@cate.com'
    userForLogin.password = '123456789'
    userForLogin.password_confirmation = '123456789'
    userForLogin.save!
    userForLogin
  end

  def self.create_one_balance(index = '')

    balance = Balance.create!(
      project: "project#{index}",
      client: "client#{index}",
      description: "description#{index}",
      date: Date.strptime(Time.now.to_s, '%Y-%m-%d')
    )
    balance
  end

  def self.create_balances(amount)
    Balance.delete_all
    balances = []
    (1..amount.to_i).each_with_index do |index|
      balances.push(create_one_balance index)
    end
    balances
  end

  def self.clean_balances
    Balance.delete_all
    Income.delete_all
    Expense.delete_all
    Distribution.delete_all
    Percentage.delete_all
    Saldo.delete_all
  end

  def self.create_kleerers

    if Option.count <= 0
      Option.delete_all
      Option.create!(name: 'Socio', value: 5)
      Option.create!(name: 'Full', value: 15)
      Option.create!(name: 'Parcial', value: 25)
      Option.create!(name: 'Otro', value: 10)
      Option.create!(name: 'Home', value: 0)
    end

    if Kleerer.count <= 0
      Kleerer.delete_all
      Kleerer.create!(name: 'Socio', option_id: Option.find_by(name: 'Socio').id)
      Kleerer.create!(name: 'Full', option_id: Option.find_by(name: 'Full').id)
      Kleerer.create!(name: 'Parcial', option_id: Option.find_by(name: 'Parcial').id)
      Kleerer.create!(name: 'Otro', option_id: Option.find_by(name: 'Otro').id)
      Kleerer.create!(name: 'KleerCo', option_id: Option.find_by(name: 'Home').id)
    end
  end

  def self.create_taxes
    TaxMaster.create!(name: 'ica',
                         value: 1.1,
                         type_tax: :invoiced)

    TaxMaster.create!(name: 'chanchito',
                               value: 2.5,
                               type_tax: :invoiced)
    TaxMaster.create!(name: 'retefuente',
                                value: 26,
                                type_tax: :utility)
    TaxMaster.create!(name: 'kleerCo',
                             value: 10,
                             type_tax: :post_utility)
  end

  def self.create_kleer_tax
    TaxMaster.create!(name: 'kleerCo',
                      value: 16,
                      type_tax: :post_utility)
  end
end
