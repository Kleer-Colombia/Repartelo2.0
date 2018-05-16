Feature:
  As Yamit
  I want to calculate a balance
  In order to know what is the money distribution

  @javascript
  Scenario: calculate balance with yamit as a kleerer
    Given I logged
    And I have kleerers
    And I create a new balance for client "Sparkta"
    And I add income for "1100.00"
    And I add expense for "100.00"
    When I calculate the balances with "Socio" as a kleerer
    And I distribute the profit
    Then I should see "$221,00" for "KleerCo"
    And I should see "$779,00" for "Socio"

  @javascript
  Scenario: calculate balance with negative profit
    Given I logged
    And I have kleerers
    And I create a new balance for client "Sparkta"
    And I add income for "100.00"
    And I add expense for "1100.00"
    When I calculate the balances with "Full" as a kleerer
    And I distribute the profit
    Then I should the an invalid profit distribution error

  @javascript
  Scenario: calculate distributions with Full and Socio
    Given I logged
    And I have kleerers
    And I create a new balance for client "Corbeta"
    And I add income for "1100.00"
    And I add expense for "200.00"
    And I calculate the balances with "Full" as a kleerer
    And I calculate the balances with "Socio" as a kleerer
    When I distribute the profit
    Then I should see "$313,65" for "Full"
    And I should see "$350,55" for "Socio"
    And I should see "$235,80" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full and Socio on 70/30
    Given I logged
    And I have kleerers
    And I create a new balance for client "Corbeta"
    And I add income for "1100.00"
    And I add expense for "200.00"
    And I calculate the balances with "Full" as a kleerer
    And I calculate the balances with "Socio" as a kleerer
    And the percentage for "Full" is "70"
    And the percentage for "Socio" is "30"
    When I distribute the profit
    Then I should see "$439,11" for "Full"
    And I should see "$210,33" for "Socio"
    And I should see "$250,56" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full, Socio and Partial
    Given I logged
    And I have kleerers
    And I create a new balance for client "Corbeta"
    And I add income for "1000.00"
    And I calculate the balances with "Full" as a kleerer
    And I calculate the balances with "Socio" as a kleerer
    And I calculate the balances with "Parcial" as a kleerer
    And the percentage for "Full" is "50"
    And the percentage for "Socio" is "25"
    And the percentage for "Parcial" is "25"
    When I distribute the profit
    Then I should see "$348,50" for "Full"
    And I should see "$194,75" for "Socio"
    And I should see "$153,75" for "Parcial"
    And I should see "$303,00" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full, Socio and Partial with  custom values
    Given I logged
    And I have kleerers
    And I create a new balance for client "Test"
    And I add income for "1000.00"
    And I calculate the balances with "Full" as a kleerer
    And I calculate the balances with "Socio" as a kleerer
    And I calculate the balances with "Parcial" as a kleerer
    And the percentage for "Full" is "50"
    And the percentage for "Socio" is "40"
    And the percentage for "Parcial" is "10"
    When I distribute the profit
    Then I should see "$348,50" for "Full"
    And I should see "$311,60" for "Socio"
    And I should see "$61,50" for "Parcial"
    And I should see "$278,40" for "KleerCo"

