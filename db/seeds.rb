# Datos de ejemplo para desarrollo local. Idempotente: correr `rails db:seed`
# las veces que haga falta no duplica nada.

option_by_name = {}
{ 'Socio' => 5, 'Full' => 15, 'Parcial' => 25, 'Otro' => 10, 'Home' => 0 }.each do |name, value|
  option_by_name[name] = Option.find_or_create_by!(name: name) { |o| o.value = value }
end

kleerco = Kleerer.find_or_create_by!(name: 'KleerCo') { |k| k.option = option_by_name['Home'] }

kleerer_by_name = {}
{ 'Camilo' => 'Socio', 'Leo' => 'Socio', 'Juli' => 'Parcial', 'Pablo' => 'Full', 'Jader' => 'Otro' }.each do |name, option_name|
  kleerer_by_name[name] = Kleerer.find_or_create_by!(name: name) { |k| k.option = option_by_name[option_name] }
end
camilo, leo, juli, pablo_k, jader = kleerer_by_name.values_at('Camilo', 'Leo', 'Juli', 'Pablo', 'Jader')

TaxMaster.find_or_create_by!(name: 'kleerCo')       { |t| t.value = 10;    t.type_tax = 'post_utility' }
TaxMaster.find_or_create_by!(name: 'Clearing')      { |t| t.value = 5;     t.type_tax = 'post_utility' }
TaxMaster.find_or_create_by!(name: 'IVA')           { |t| t.value = 19;    t.type_tax = 'in_alegra' }
TaxMaster.find_or_create_by!(name: 'RETEFUENTE')    { |t| t.value = 11;    t.type_tax = 'invoiced' }
TaxMaster.find_or_create_by!(name: 'RETEICA')       { |t| t.value = 0.966; t.type_tax = 'invoiced' }
TaxMaster.find_or_create_by!(name: 'Utilidad')      { |t| t.value = 20;    t.type_tax = 'utility' }
TaxMaster.find_or_create_by!(name: 'Reserva legal') { |t| t.value = 10;    t.type_tax = 'reservas' }

FeatureFlag.find_or_create_by!(feature: FeatureFlag::ALEGRA_INVOICE_MOCK) { |f| f.status = true }

# 'default' es un país fijo que usa la pantalla general de Clearings
# (clearings#find_default_clearings busca Country.find_by(name: 'default')
# sin manejar el caso nil); en producción se administra a mano vía ActiveAdmin.
default_country = Country.find_or_create_by!(name: 'default')
Country.find_or_create_by!(name: 'Colombia')
Clearing.find_or_create_by!(country_id: default_country.id, description: 'Ajuste cambiario ejemplo') do |c|
  c.amount = 250_000
  c.final_amount = 237_500
  c.percentage = 5
  c.ext_kleerer = 'Cliente externo'
end

# Balance abierto, en curso, repartido entre dos kleerers.
balance_abierto = Balance.find_or_create_by!(client: 'Acme Corp', project: 'Rediseño web') do |b|
  b.date = 1.month.ago.to_date
  b.description = 'Proyecto de rediseño de sitio institucional'
  b.kleerer = camilo
end
balance_abierto.incomes.find_or_create_by!(description: 'Anticipo 50%') { |i| i.amount = 8_000_000 }
balance_abierto.expenses.find_or_create_by!(description: 'Hosting + dominios') { |e| e.amount = 150_000 }
balance_abierto.expenses.find_or_create_by!(description: 'Freelance diseño') { |e| e.amount = 1_200_000 }
Percentage.find_or_create_by!(balance: balance_abierto, kleerer: camilo) { |p| p.value = 60 }
Percentage.find_or_create_by!(balance: balance_abierto, kleerer: leo)    { |p| p.value = 40 }

# Segundo balance abierto, con un solo kleerer a cargo.
balance_abierto2 = Balance.find_or_create_by!(client: 'Norte SAS', project: 'Consultoría de procesos') do |b|
  b.date = 10.days.ago.to_date
  b.description = 'Consultoría puntual, aún sin cerrar'
  b.kleerer = pablo_k
end
balance_abierto2.incomes.find_or_create_by!(description: 'Pago único') { |i| i.amount = 4_500_000 }
Percentage.find_or_create_by!(balance: balance_abierto2, kleerer: pablo_k) { |p| p.value = 100 }

# Balance cerrado, con distribución y saldos ya calculados.
balance_cerrado = Balance.find_or_create_by!(client: 'Beta Ltda', project: 'App móvil de pedidos') do |b|
  b.date = 3.months.ago.to_date
  b.description = 'Balance cerrado de ejemplo, con distribución ya calculada'
  b.editable = false
  b.kleerer = juli
end
balance_cerrado.incomes.find_or_create_by!(description: 'Pago único') { |i| i.amount = 12_000_000 }
balance_cerrado.expenses.find_or_create_by!(description: 'Infraestructura AWS') { |e| e.amount = 900_000 }
Percentage.find_or_create_by!(balance: balance_cerrado, kleerer: juli)  { |p| p.value = 70 }
Percentage.find_or_create_by!(balance: balance_cerrado, kleerer: jader) { |p| p.value = 30 }

Distribution.find_or_create_by!(balance: balance_cerrado, kleerer: kleerco) { |d| d.amount = 1_500_000 }
Distribution.find_or_create_by!(balance: balance_cerrado, kleerer: juli)    { |d| d.amount = 6_650_000 }
Distribution.find_or_create_by!(balance: balance_cerrado, kleerer: jader)   { |d| d.amount = 2_850_000 }

Saldo.find_or_create_by!(kleerer: juli, reference: balance_cerrado.project, concept: 'Distribución') do |s|
  s.amount = 6_650_000
  s.balance = balance_cerrado
end
Saldo.find_or_create_by!(kleerer: jader, reference: balance_cerrado.project, concept: 'Distribución') do |s|
  s.amount = 2_850_000
  s.balance = balance_cerrado
end

User.find_or_create_by!(email: 'pablo.test@repartelo.local') do |u|
  u.name = 'Pablo Test'
  u.password = 'repartelo123'
  u.password_confirmation = 'repartelo123'
end

AdminUser.find_or_create_by!(email: 'admin@repartelo.local') do |a|
  a.password = 'repartelo123'
  a.password_confirmation = 'repartelo123'
end

puts "Seed OK: #{Kleerer.count} kleerers, #{Balance.count} balances, #{Country.count} countries, #{Clearing.count} clearings, #{User.count} users, #{AdminUser.count} admin_users"
