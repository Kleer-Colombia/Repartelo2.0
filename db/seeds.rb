# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#AdminUser.create!(email: 'ali@cate.com', password: '123456789', password_confirmation: '123456789')
User.create!(name: 'ali cate', email: 'ali@cate.com', password: '123456789', password_confirmation: '123456789')

Option.delete_all
Option.create!(name: 'Socio', value: 5)
Option.create!(name: 'Full', value: 15)
Option.create!(name: 'Parcial', value: 25)
Option.create!(name: 'Otro', value: 10)
Option.create!(name: 'Home', value: 0)

Kleerer.delete_all
Kleerer.create!(name: 'Socio', option_id: Option.find_by(name: 'Socio').id)
Kleerer.create!(name: 'Full', option_id: Option.find_by(name: 'Full').id)
Kleerer.create!(name: 'Parcial', option_id: Option.find_by(name: 'Parcial').id)
Kleerer.create!(name: 'Otro', option_id: Option.find_by(name: 'Otro').id)
Kleerer.create!(name: 'KleerCo', option_id: Option.find_by(name: 'Home').id)

FeatureFlag.create!(feature: "balance-incomes", status: true)
FeatureFlag.create!(feature: "balance-invoices", status: true)

TaxMaster.create!(name: 'kleerCo',
                  value: 16,
                  type_tax: :post_utility)
TaxMaster.create!(name: 'IVA',
                  value: 0,
                  type_tax: :in_alegra)