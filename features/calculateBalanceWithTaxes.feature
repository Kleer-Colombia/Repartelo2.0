Feature:
  As Yamit
  I want to calculate a balance
  In order to know what is the money distribution

  @javascript
  Scenario: calculate balance with yamit as a kleerer
    Given I have data for balances
    And I logged
    And I have taxes
    And I create a new standard balance for client "Sparkta"
    And I add income for "1000.00"
    And I add expense for "10.00"
    When I select "Socio" as a kleerer
    And I distribute the profit
    Then I should see "$25,00" for "Chanchito"
    Then I should see "$11,00" for "Ica"
    Then I should see "$705,96" for "utilidad"
    Then I should see "$248,04" for "Retefuente"
    Then I should see "$102,37" for "KleerCo"
    And I should see "$603,59" for "Socio"

  @javascript
  Scenario: calculate distributions with Full and Socio
    Given I have data for balances
    And I logged
    And I have taxes
    And I create a new standard balance for client "Corbeta"
    And I add income for "1100.00"
    And I add expense for "200.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    When I distribute the profit
    Then I should see "$27,50" for "Chanchito"
    Then I should see "$12,10" for "Ica"
    Then I should see "$636,70" for "utilidad"
    Then I should see "$223,70" for "Retefuente"
    Then I should see "$243,54" for "Full"
    And I should see "$272,19" for "Socio"
    And I should see "$120,97" for "KleerCo"

  @javascript
  Scenario: calculate distributions with  custom values
    Given I have data for balances
    And I logged
    And I have taxes
    And I create a new standard balance for client "Test"
    And I add income for "1000.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    And I select "Parcial" as a kleerer
    And the percentage for "Full" is "50"
    And the percentage for "Socio" is "40"
    And the percentage for "Parcial" is "10"
    When I distribute the profit
    Then I should see "$25,00" for "Chanchito"
    Then I should see "$11,00" for "Ica"
    Then I should see "$713,36" for "utilidad"
    Then I should see "$250,64" for "Retefuente"
    Then I should see "$243,97" for "Socio"
    And I should see "$148,38" for "KleerCo"
    And I should see "$272,86" for "Full"
    And I should see "$48,15" for "Parcial"

