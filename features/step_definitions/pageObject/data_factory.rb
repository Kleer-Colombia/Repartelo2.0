# frozen_string_literal: true
require 'csv'

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
    Tax.delete_all
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
    TaxMaster.delete_all
    TaxMaster.create!(name: 'Ica',
                         value: 1.1,
                         type_tax: :invoiced)
    TaxMaster.create!(name: 'Chanchito',
                               value: 2.5,
                               type_tax: :invoiced)
    TaxMaster.create!(name: 'Retefuente',
                                value: 26,
                                type_tax: :utility)
    TaxMaster.create!(name: 'kleerCo',
                             value: 10,
                             type_tax: :post_utility)
    TaxMaster.create!(name: 'IVA',
                      value: 0,
                      type_tax: :in_alegra)
  end

  def self.create_kleer_tax
    TaxMaster.create!(name: 'kleerCo',
                      value: 16,
                      type_tax: :post_utility)
  end

  def self.enable_incomes
    FeatureFlag.create!(feature: "balance-incomes", status: true)
  end

  def self.enable_invoices
    FeatureFlag.create!(feature: "balance-invoices", status: true)
  end

  def self.enable_alegra_mock
    FeatureFlag.create!(feature: FeatureFlag::ALEGRA_INVOICE_MOCK, status: true)
  end

  def self.load_balances
   load_file('balances.tsv',Balance)
  end

  def self.load_taxes
    load_file('taxes.tsv',Tax)
  end

  private

  def self.load_file(filename, entity)
    entity.delete_all
    puts ActiveRecord::Base.connection.current_database
    puts "Entity: #{entity}, size: #{entity.all.size}"
    csv_text = File.read("#{Dir.pwd}/features/data/#{filename}")
    csv = CSV.parse(csv_text, :headers => true, :col_sep => "\t")
    csv.each do |row|
      entity.create!(row.to_hash)
    end
    puts "Entity: #{entity}, loaded: #{entity.all.size}"
  end
end
