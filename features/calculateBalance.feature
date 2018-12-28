Feature:
  As Yamit
  I want to calculate a balance
  In order to know what is the money distribution

  @javascript
  Scenario: calculate balance with yamit as a kleerer
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Sparkta"
    And I add income for "1100.00"
    And I add expense for "100.00"
    When I select "Socio" as a kleerer
    And I distribute the profit
    Then I should see "$202,00" for "KleerCo"
    And I should see "$798,00" for "Socio"

  @javascript
  Scenario: calculate balance with negative profit
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Sparkta"
    And I add income for "100.00"
    And I add expense for "1100.00"
    When I select "Full" as a kleerer
    And I distribute the profit
    Then I should the an invalid profit distribution error

  @javascript
  Scenario: calculate distributions with Full and Socio
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Corbeta"
    And I add income for "1100.00"
    And I add expense for "200.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    When I distribute the profit
    Then I should see "$321,30" for "Full"
    And I should see "$359,10" for "Socio"
    And I should see "$219,60" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full and Socio on 70/30
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Corbeta"
    And I add income for "1100.00"
    And I add expense for "200.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    And the percentage for "Full" is "70"
    And the percentage for "Socio" is "30"
    When I distribute the profit
    Then I should see "$449,82" for "Full"
    And I should see "$215,46" for "Socio"
    And I should see "$234,72" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full, Socio and Partial
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Corbeta"
    And I add income for "1000.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    And I select "Parcial" as a kleerer
    And the percentage for "Full" is "50"
    And the percentage for "Socio" is "25"
    And the percentage for "Parcial" is "25"
    When I distribute the profit
    Then I should see "$357,00" for "Full"
    And I should see "$199,50" for "Socio"
    And I should see "$157,50" for "Parcial"
    And I should see "$286,00" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full, Socio and Partial with  custom values
    Given I logged
    And I have kleerers
    And I have kleer tax
    And I create a new standard balance for client "Test"
    And I add income for "1000.00"
    And I select "Full" as a kleerer
    And I select "Socio" as a kleerer
    And I select "Parcial" as a kleerer
    And the percentage for "Full" is "50"
    And the percentage for "Socio" is "40"
    And the percentage for "Parcial" is "10"
    When I distribute the profit
    Then I should see "$357,00" for "Full"
    And I should see "$319,20" for "Socio"
    And I should see "$63,00" for "Parcial"
    And I should see "$260,80" for "KleerCo"

