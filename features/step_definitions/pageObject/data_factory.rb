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
    if Kleerer.count <= 0
      Kleerer.delete_all
      Kleerer.create!(name: 'Socio', option: :socio)
      Kleerer.create!(name: 'Full', option: :full)
      Kleerer.create!(name: 'Parcial', option: :parcial)
      Kleerer.create!(name: 'Otro', option: :otro)
      Kleerer.create!(name: 'KleerCo', option: :home)
    end
  end
end
